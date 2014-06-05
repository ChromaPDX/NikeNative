//
//  NIKEErrors.h
//  SDK
//
//  Created by Nike on 10/10/13.
//  Copyright (c) 2013 Nike, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const NIKEErrorDomain;
FOUNDATION_EXPORT NSString *const NIKEExceptionName;
FOUNDATION_EXTERN NSString *const NIKEErrorDescription;

FOUNDATION_EXTERN NSString *const NIKEErrorData;
FOUNDATION_EXTERN NSString *const NIKEErrorNSURLHTTPResponse;

typedef NS_ENUM(NSInteger, NIKEErrorCode)
{
    NIKEErrorCodeUnknown,
    NIKEErrorCodeNotSupported,
    NIKEErrorCodeAuthorization,
    NIKEErrorCodeKeychain,
};
