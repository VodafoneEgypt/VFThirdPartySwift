//
//  LanguageHandler.m
//  Youth
//
//  Created by Karim Mousa on 4/28/15.
//  Copyright (c) 2015 Karim Mousa. All rights reserved.
//

#import "LanguageHandler.h"

/**
 * LanguageHandler : singlton to handle language, direction and bundle
 */

#define CurrentLanguage_Default @"CurrentLanguage_Default"
#define CurrentDirection_Default @"CurrentDirection_Default"
#define FirstRun_Default @"FirstRun_Default"
#define LanguageSuite_Default @"LanguageSuite_Default"

@interface LanguageHandler()

@property (nonatomic,strong,readonly) NSBundle* currentBundle;

@end

@implementation LanguageHandler

- (void)setDirection:(DirectionType)direction AndLanguage:(LanguageType)language{
    
    [self setCurrentDirection:direction];
    
    [self setCurrentLanguage:language];
}

- (NSString*) stringForKey:(NSString*)key{
    
    NSString* result = [_currentBundle localizedStringForKey:key value:key table:nil];
    
    return result;
}

#pragma mark - private -

-(void) adjustBundle{
    
    NSString *lang = nil;
    
    switch (_currentLanguage) {
        case ENGLISH:
            lang = @"Base";
            break;
        case ARABIC:
            lang = @"ar";
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"];
    _currentBundle = [NSBundle bundleWithPath:bundlePath];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:LanguageChangedNotification object:nil];
}

- (void) setDefaultAppSettings{
    
    NSString * language = [NSLocale preferredLanguages].firstObject;
    
    if([language isEqualToString:@"ar"]){
        
        [self setDirection:RTL AndLanguage:ARABIC];
    }else{
        
        [self setDirection:LTR AndLanguage:ENGLISH];
    }
}

#pragma mark setters
-(void)setCurrentLanguage:(LanguageType)lang{
    
    if(_currentLanguage != lang || !_currentBundle){
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:LanguageSuite_Default];
        
        [sharedDefaults setObject:@(lang) forKey:CurrentLanguage_Default];
        
        [sharedDefaults synchronize];
        
        _currentLanguage = lang;
        
        [self adjustBundle];
    }
}

-(void)setCurrentDirection:(DirectionType)rtl{
    
    _currentDirection = rtl;
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:LanguageSuite_Default];
    
    [sharedDefaults setObject:@(rtl) forKey:CurrentDirection_Default];
    
    [sharedDefaults synchronize];
}

#pragma mark initialization

-(void)initialize{
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:LanguageSuite_Default];
    
    NSNumber *language = [sharedDefaults objectForKey:CurrentLanguage_Default];
    
    if(language == nil){
        // first time run
        [self setDefaultAppSettings];
    }else{
        
        NSNumber* direction = [sharedDefaults objectForKey:CurrentDirection_Default];
        
        [self setDirection:direction.integerValue AndLanguage:language.integerValue];
    }
}

#pragma mark - singlton implementation

+ (instancetype)sharedInstance{
    
    static LanguageHandler *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[super allocWithZone:NULL]init];
        
        [sharedInstance initialize];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

@end
