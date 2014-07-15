//
//  OAToken+storage.m
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 6/2/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import "LIOAToken.h"

#import "LIOAToken+storage.h"


@implementation LIOAToken (OAToken_RDLinkedIn_storage)

+ (NSString *)rd_defaultsKeyForKeyWithProviderName:(NSString *)provider prefix:(NSString *)prefix
{
  NSParameterAssert(provider);
  NSParameterAssert(prefix);
  
  return [NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, provider];
}

+ (NSString *)rd_defaultsKeyForSecretWithProviderName:(NSString *)provider prefix:(NSString *)prefix
{
  return [NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, provider];
}

+ (LIOAToken *)rd_tokenWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix
{
    LIOAToken* token = nil;
    NSMutableDictionary *dict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist"])
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist"];
    else
        dict = [NSMutableDictionary dictionary];
    NSString *key = [dict objectForKey:[self rd_defaultsKeyForKeyWithProviderName:provider prefix:prefix]];
    NSString *secret = [dict objectForKey:[self rd_defaultsKeyForSecretWithProviderName:provider prefix:prefix]];
  
    if( [key length] > 0 && [secret length] > 0 ) {
        token = [[[LIOAToken alloc] initWithKey:key secret:secret] autorelease];
    }
    
    return token;
}

+ (void)rd_clearUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix
{
    NSMutableDictionary *dict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist"])
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist"];
    else
        dict = [NSMutableDictionary dictionary];
        
    if ([dict objectForKey:[[self class] rd_defaultsKeyForKeyWithProviderName:provider prefix:prefix]])
        [dict removeObjectForKey:[[self class] rd_defaultsKeyForKeyWithProviderName:provider prefix:prefix]];
    if ([dict objectForKey:[[self class] rd_defaultsKeyForSecretWithProviderName:provider prefix:prefix]])
        [dict removeObjectForKey:[[self class] rd_defaultsKeyForSecretWithProviderName:provider prefix:prefix]];
    [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist" atomically:YES];
}

- (void)rd_storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix
{
    NSMutableDictionary *dict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist"])
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist"];
    else
        dict = [NSMutableDictionary dictionary];
        
    [dict setObject:self.key forKey:[[self class] rd_defaultsKeyForKeyWithProviderName:provider prefix:prefix]];
    [dict setObject:self.secret forKey:[[self class] rd_defaultsKeyForSecretWithProviderName:provider prefix:prefix]];
    [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.linkedinpluginprefs.plist" atomically:YES];
}

@end
