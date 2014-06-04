//
//  NIKERequest.h
//
//  Copyright (c) 2013 Nike. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString NIKEURLComponents;
// NSURL
FOUNDATION_EXTERN NIKEURLComponents *const NIKESchemeKey;
FOUNDATION_EXTERN NIKEURLComponents *const NIKEHostKey;
FOUNDATION_EXTERN NIKEURLComponents *const NIKEPathKey;
FOUNDATION_EXTERN NIKEURLComponents *const NIKEURLQueryParamsKey;
FOUNDATION_EXTERN NIKEURLComponents *const NIKEURLAccessTokenParamKey;

// NSURLRequest
typedef NSString NIKEURLRequestParameters;
FOUNDATION_EXTERN NIKEURLRequestParameters *const NIKEHTTPHeadersKey;
FOUNDATION_EXTERN NIKEURLRequestParameters *const NIKEHTTPMethodKey;

// NSURLReqeust HTTPBody
FOUNDATION_EXTERN NIKEURLRequestParameters *const NIKEHTTPBodyKey;
FOUNDATION_EXTERN NIKEURLRequestParameters *const NIKEHTTPFormBodyKey;

/*!
 Basic request class for the Nike SDK.
 */
@class NIKECredential;
@interface NIKERequest : NSObject

/*! URL */
@property (nonatomic, readonly) NSURL *URL;
/*! Header fields */
@property (nonatomic) NSDictionary *HTTPHeaderFields;
/*! HTTP Method, default is GET */
@property (nonatomic) NSString *HTTPMethod;
/*! Body for the request. */
@property (nonatomic) NSData *HTTPBody;
/*! Query paramters. These are appended to the URL when creating a NSMutableURLRequest */
@property (nonatomic) NSDictionary *queryParams;
/*! Nike credential for the request. */
@property (nonatomic) NIKECredential *credential;


//---------------------------------------------------------------------------------------
// Initialization
//---------------------------------------------------------------------------------------

/*! 
 Initialize a NIKERequest with the given URL.
 
 @param URL URL for the request
 @return Request object with URL
 */
- (instancetype)initWithURL:(NSURL *)URL;

/*!
 Initialize the request with the URL and credential. The credential will be used to 
 authenticate requrest by appending an access_token query param.
 
 @param URL URL for the request
 @param credential Credential for the request
 @return Request object with URL and credential
 */
- (instancetype)initWithURL:(NSURL *)URL credential:(NIKECredential *)credential;


//---------------------------------------------------------------------------------------
// NSURLRequest 
//---------------------------------------------------------------------------------------

- (NSMutableURLRequest *)mutableURLRequest;

@end