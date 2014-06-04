//
//  NIKEURLHelper.h
//  Core
//

//  Copyright (c) 2013 Nike. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const NIKEURLSchemeComponent;
extern NSString *const NIKEURLHostComponent;
extern NSString *const NIKEURLPortComponent;
extern NSString *const NIKEURLUserComponent;
extern NSString *const NIKEURLPasswordComponent;
extern NSString *const NIKEURLPathComponent;
extern NSString *const NIKEURLParameterStringComponent;
extern NSString *const NIKEURLQueryComponent;
extern NSString *const NIKEURLFragmentComponent;

@interface NIKEURLHelper : NSObject

/*! Encodes a string for use in a URL query parameter
 @param unencoded The string to be encoded.
 @result A URL-encoded string. Note that space will be encoded as %20, not +
 */
+ (NSString *)URLEncodedString:(NSString *)unencoded;

/*! Decodes a URL-encoded or form-encoded string
 @param encoded The string to be decoded.
 @result An unencoded string. Note that + will be converted to a space
 */
+ (NSString *)URLDecodedString:(NSString *)unencoded;

/*! Generates a query string from a dictionary of parameters
 @param parameters The parameter dictionary. Keys must be strings, but values can be NSNumbers or other object types.
 @result A URL or post body-friendly query string, without the leading ?
 */
+ (NSString *)queryStringWithParameters:(NSDictionary *)parameters;

/*! Generates a dictionary of parameters from a query string
 @param queryString The query parameter string. The method will locate a query string inside a URL, so it's fine to pass an entire URL string to this method, including path, fragment ID, etc.
 @result An dictionary of (already URL-decoded) query parameters.
 */
+ (NSDictionary *)queryParametersFromString:(NSString *)queryString;

/*! Constructs a URL from a dictionary of component parts
 @param components A dictionary of URL components. These should all be strings, with the exception of the NIKEURLQueryComponent, which can either be a query string or a dictionary of parameters.
 @result An NSURL. This may be fully-qualified or relative, depending on parameters passed.
 */
+ (NSURL *)URLWithComponents:(NSDictionary *)components;

/*! Returns all of the individual component parts from a URL
 @param URL An NSURL.
 @result A dictionary containing some or all of the NIKEURL*Component values.
 */
+ (NSDictionary *)URLComponents:(NSURL *)URL;

/*! Adds or replaces the NSURLCredential in the supplied URL
 @param baseURL The URL that should have a credential applied.
 @param credential An NSURLCredential to apply to the baseURL.
 @result An NSURL containing the supplied credential.
 */
+ (NSURL *)URLWithBaseURL:(NSURL *)baseURL credential:(NSURLCredential *)credential;

/*! Sets or appends the query string to the supplied URL
 @param baseURL The URL that should have a credential applied.
 @param queryString The query string to append to the URL. Appending is done intelligently, so that any existing query parameters are retained, and any duplicates will be replaced by the new value. The parameter order is not guaranteed.
 @result An NSURL containing the supplied query values.
 */
+ (NSURL *)URLWithBaseURL:(NSURL *)baseURL queryString:(NSString *)queryString;

/*! Sets or appends the query string to the supplied URL
 @param baseURL The URL that should have a credential applied.
 @param parameters The query parameters to append to the URL. Appending is done intelligently, so that any existing query parameters are retained, and any duplicates will be replaced by the new value. The parameter order is not guaranteed.
 @result An NSURL containing the supplied query parameters.
 */
+ (NSURL *)URLWithBaseURL:(NSURL *)baseURL queryParameters:(NSDictionary *)parameters;

@end
