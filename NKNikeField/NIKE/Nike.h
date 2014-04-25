//
//  Nike.h
//
//  Copyright (c) 2013 Nike, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIKECredential.h"

typedef enum
{
    NikeLogLevelNone = 0, //default for device
    NikeLogLevelError = 1,
    NikeLogLevelWarn = 2,
    NikeLogLevelInfo = 4,
    NikeLogLevelVerbose = 8 //default for simulator
}
NikeLogLevel;

/*! Nike logging macro. Use this instead of NSLog.
 @param level The logging level (required).
 @param ... The format string, followed by any params (required).
 */
#define NikeLog(level, ...) \
[Nike logWithLevel:level \
file:__FILE__ \
function:sel_getName(_cmd) \
line:__LINE__ \
format:__VA_ARGS__]

typedef NSString *const NikeHTTPMethod;
extern NikeHTTPMethod NikeHTTPMethodGET;
extern NikeHTTPMethod NikeHTTPMethodPOST;
extern NikeHTTPMethod NikeHTTPMethodPUT;
extern NikeHTTPMethod NikeHTTPMethodDELETE;

/*! Standard response handler block for Nike service requests
 @param success YES if the request was successful, otherwise NO.
 @param json The response body data in JSON format (nil if the request failed).
 @param error The error (nil if the request was successful or if error was unknown).
 */
typedef void (^NikeResponseHandler)(BOOL success, id json, NSError *error);

/*! Provides access to the central functions of the Nike+ SDK. Use this class to authorize a user and make network
 requests. SDK logging access is provided to assist with debugging.
 
 Special considerations: this object must only be called on the main thread. Calling this object from another thread will
 result in an exception being thrown.
 */
@interface Nike : NSObject

/*! Gets the version number for the current Nike SDK release
 @result A string representing the Nike SDK version.
 */
+ (NSString *)version;

/*! Set the logging level for the Nike SDK
 @param level The maximum logging level that will be displayed (required).
 */
+ (void)setLogLevel:(NikeLogLevel)level;

/*! The designated logging method.
 @param level The logging level (required).
 @param file The name of the current file (required).
 @param function The name of the current function (required).
 @param format The string to be logged (required).
 @param ... values used by the format string (optional).
 */
+ (void)logWithLevel:(NikeLogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ... __attribute__ ((format (__NSString__, 5, 6)));

/*! Checks if there is a currently logged in user
 @result YES if there is an active user, otherwise NO.
 */
+ (BOOL)isLoggedIn;

/*! Returns the current user's credential, including the user's identifier and access and refresh tokens.
 */
+ (NIKECredential *)credential;

/*! Logs in an existing Nike user
 @param completion A NikeResponseHandler block (required).
 */
+ (void)logInWithCompletion:(NikeResponseHandler)completion;

/*! Handle a web-based login callback url
 @param url A potential login url (required).
 @result If Nike has handled the url this returns YES. If it returns NO, the client app should handle it.
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/*! Logs out the currently active user
 @param username The user's username (required).
 @param password The user's password (required).
 @param completion A NikeResponseHandler block (required).
 */
+ (void)logOut;

/*! Makes an authenticated service request
 @param method The RESTful request method type (required).
 @param path The service path to invoke (required).
 @param parameters A dictionary of query parameters to be appended to the URL (optional).
 @param bodyData Either a UIImage (for mime data upload) or a dictionary of json parameters (optional).
 @param completion A NikeResponseHandler block (required).
 */
+ (void)performRequestWithHTTPMethod:(NikeHTTPMethod)method
                                path:(NSString *)path
                          parameters:(NSDictionary *)parameters
                            bodyData:(id)bodyData
                          completion:(NikeResponseHandler)completion;

@end
