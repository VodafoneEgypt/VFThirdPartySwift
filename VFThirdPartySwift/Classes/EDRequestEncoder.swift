//
//  EDRequestEncoder.swift
//  EDHmacClient
//
//  Created by Tischuk, Christopher on 2/10/16.
//  Copyright © 2016 Edmunds.com, Inc. All rights reserved.
/**
    Encodes an outbound NSMutableURLRequest with security credentials
    so that it can be authenticated on the receiving server using HMAC
    authentication.

    After initializing and configuring an instance of NSMutableURLRequest,
    encodeRequest adds the necessary HTTP request headers and signature
    for HMAC authenticatation.

    If you need to change the names of the query parameter and headers used
    by HMAC, you can do so after initialization by setting:
    -apiKeyQueryParameter
    -signatureHTTPHeader
    -timestampHTTPHeader
    -versionHTTPHeader
*/

import Foundation
import CommonCryptoModule

@objc public class EDRequestEncoder:NSObject {
    
    let apiKey: String
    let secretKey: String
    let useModifiedBase64ForURL: Bool
    let version = "1"
    var apiKeyQueryParameter = "apiKey"
    var signatureHTTPHeader = "X-Auth-Signature"
    var timestampHTTPHeader = "X-Auth-Timestamp"
    var versionHTTPHeader = "X-Auth-Version"
    
    /**
     - parameters:
        - apiKey: The API key.
        - secretKey: The secret key.
        - useModifiedBase64ForURL: A boolean indicating whether to use modified Base64 for URL encoding in the generated signature. Setting this to true will replace '+' and '/' characters with '-' and '_' respectively in the signature.
     */
    init(apiKey: String, secretKey: String, useModifiedBase64ForURL: Bool) {
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.useModifiedBase64ForURL = useModifiedBase64ForURL
    }
    
    // MARK: - Main Method
    
    /**
     Encodes an outbound NSMutableURLRequest.
     Any query parameter string should be added to the URL before calling this method,
     and it should NOT contain the API key as it is added here.
     
     - parameters:
        - request: The outbound NSMutableURLRequest.
     */
    func encodeRequest(request: NSMutableURLRequest) {
        let timestamp = getCurrentTimeStamp()
        self.addAPIKey(request: request)
        self.addTimeStamp( request: request, timestamp: timestamp)
        self.addSignature(request: request, timestamp: timestamp)
        self.addVersion(request: request)
    }
    
    // MARK: - Utility Methods
    
    /**
      Gets the current UTC time as a string with ISO8601 standard format:
      yyyy-MM-dd'T'HH:mm:ss'Z'.
     
     - returns: The current timestamp.
    */
    func getCurrentTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    /**
     Adds the API Key as a query parameter to the request.
     
     - parameter request: The outbound NSMutableURLRequest.
     */
    func addAPIKey(request: NSMutableURLRequest) {
        if let urlString = request.url?.absoluteString, let urlComponents = NSURLComponents(string: urlString) {
            if urlComponents.queryItems == nil {
                urlComponents.queryItems = [NSURLQueryItem(name: apiKeyQueryParameter, value: apiKey) as URLQueryItem]
            }
            else {
                urlComponents.queryItems?.append(NSURLQueryItem(name: apiKeyQueryParameter, value: apiKey) as URLQueryItem)
            }
            request.url = urlComponents.url
        }
    }
    
    func addTimeStamp(request: NSMutableURLRequest, timestamp: String) {
        request.addValue(timestamp, forHTTPHeaderField: timestampHTTPHeader)
    }
    
    func addVersion(request: NSMutableURLRequest) {
        request.addValue(version, forHTTPHeaderField: versionHTTPHeader)
    }
    
    /**
     Adds a signature to the authorization header of the outbound request.
     
     - parameters:
        - request: The outbound NSMutableURLRequest.
        - timestamp: The timestamp used to generate the signature.
     */
    func addSignature(request: NSMutableURLRequest, timestamp: String) {
//        if let signature = generateSignature(request, timestamp: timestamp) {
//            request.addValue(signature, forHTTPHeaderField: signatureHTTPHeader)
//        }
    }
    
    /**
     Generates an authentication code using HMAC-SHA256.
     
     - parameters:
        - request: The outbound NSMutableURLRequest used to generate the signature.
        - timestamp: The timestamp used to generate the signature.
     
     - returns: The encoded signature.
     */
    func generateSignature(_ request: NSMutableURLRequest, timestamp: String,nonce:String) -> String? {
        
        if let path = request.url?.path.removingPercentEncoding, let query = request.url?.query?.removingPercentEncoding {
            let delimiter = "\n"
            let message = "\(apiKey)\(request.httpMethod)\(delimiter)\(path)?\(query)\(delimiter)\(timestamp)\(nonce)"
            
            if let messageData = message.data(using: String.Encoding.utf8),
                let secretData = secretKey.data(using: String.Encoding.utf8) {
                    
                let digest = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
                let hmacContext = UnsafeMutablePointer<CCHmacContext>.allocate(capacity: 1)
                secretData.withUnsafeBytes {dataBytes in
                    CCHmacInit(hmacContext, UInt32(kCCHmacAlgSHA256),dataBytes, secretData.count)
                }
                messageData.withUnsafeBytes {dataBytes in
                    CCHmacUpdate(hmacContext, dataBytes, messageData.count)
                }

//                if let contentData = request.httpBody, let delimeterData = delimiter.data(using: String.Encoding.utf8), contentData.count > 0 {
//                    delimeterData.withUnsafeBytes {dataBytes in
//                         CCHmacUpdate(hmacContext, dataBytes, delimeterData.count)
//                    }
//                    delimeterData.withUnsafeBytes {dataBytes in
//                        CCHmacUpdate(hmacContext, dataBytes, contentData.count)
//                    }
//
//                }
                
                CCHmacFinal(hmacContext, digest)
                
                let digestData = NSData(bytes: digest, length: Int(CC_SHA256_DIGEST_LENGTH))
                var signature = digestData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                if useModifiedBase64ForURL {
                    signature = signature.replacingOccurrences(of: "/", with: "_")
                    signature = signature.replacingOccurrences(of: "+", with: "-")
                }
                return signature
            }
        }
        return nil
    }
}
