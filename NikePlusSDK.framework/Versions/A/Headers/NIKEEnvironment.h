//
//  NIKEEnvironment.h
//  NikePlusSDK
//
//  Copyright (c) 2013 Nike. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString *const NIKEEnvironmentKey;

/*! The primary Nike info dictionary key, 'Nike'.
 */
FOUNDATION_EXTERN NIKEEnvironmentKey NIKEEnvironmentInfoKey;

/*! The app id key, 'appId'.
 */
FOUNDATION_EXTERN NIKEEnvironmentKey NIKEEnvironmentAppIdKey;

/*! The client id key, 'clientId'.
 */
FOUNDATION_EXTERN NIKEEnvironmentKey NIKEEnvironmentClientIdKey;

/*! The client secret.
 */
FOUNDATION_EXTERN NIKEEnvironmentKey NIKEEnvironmentClientSecretKey;

/*! The application's registered URL scheme for Nike authentication, 'loginUrlScheme'.
 */
FOUNDATION_EXTERN NIKEEnvironmentKey NIKEEnvironmentURLSchemeKey;


@interface NIKEEnvironment : NSObject 

/* Application id */
@property (nonatomic, readonly) NSString *appId;

/* Client id */
@property (nonatomic, readonly) NSString *clientId;

/* Client secret */
@property (nonatomic, readonly) NSString *clientSecret;

/* The Nike configuration information from the Info.plist */
@property (nonatomic, readonly) NSDictionary *info;

/* The registered URL scheme in the Info.plist */
@property (nonatomic, readonly) NSString *registeredURLScheme;

/*! 
 Create a NIKEEnvironment with the given information.
 @param info Dictionary with keys and values required by the Nike environment
 @return Configured NIKEEnvironment
 */
- (instancetype)initWithEnvironmentInfo:(NSDictionary *)info;

/*!
 Current SDK version
 @return version
 */
- (NSString *)version;

/*!
 Returns a Nike environment configured with the parameters in the Info.plist
 @return Environment configured with Info.plist values
 */
 + (NIKEEnvironment *)defaultEnvironment;
@end
