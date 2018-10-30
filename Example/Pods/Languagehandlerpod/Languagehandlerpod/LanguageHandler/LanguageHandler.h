//
//  LanguageHandler.h
//  Youth
//
//  Created by Karim Mousa on 4/28/15.
//  Copyright (c) 2015 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
	ENGLISH = 0,
	ARABIC = 1
}LanguageType;

typedef enum : NSInteger {
	LTR = 0,
	RTL = 1
}DirectionType;

@interface LanguageHandler : NSObject

@property (nonatomic,readonly) LanguageType currentLanguage;

@property (nonatomic,readonly) DirectionType currentDirection;

+ (instancetype) sharedInstance;

- (void) setDirection:(DirectionType)direction AndLanguage:(LanguageType)language;

- (NSString*) stringForKey:(NSString*)key;

@end
