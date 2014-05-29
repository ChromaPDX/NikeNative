//
//  Nike.h
//
//  Copyright (c) 2013 Nike, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIKECredential.h"
#import "NIKEErrors.h"
#import "NIKELogLevels.h"
#import "NIKERequest.h"
#import "AvailabilityMacros.h"


typedef NSString NIKENotification;

/*! Notification posted when a login error has occured */
FOUNDATION_EXTERN NIKENotification *const NIKELoginErrorNotification;

/*! Notfication posted when a user's login state has changed */
FOUNDATION_EXTERN NIKENotification *const NIKELoginStateChangedNotification;

/*! Key for login state value in NSNotification info dictionary */
FOUNDATION_EXTERN NIKENotification *const NIKELoginStateKey;

/*! Notification posted when a user has completed the login flow and a token 
    has been stored */
FOUNDATION_EXTERN NIKENotification *const NIKEDidLogin;

/*! Notification posted when a user had logged out */
FOUNDATION_EXTERN NIKENotification *const NIKEDidLogout;


/*! 
 Provides access to the central functions of the Nike+ SDK. Use this class to authorize a user and make network
 requests.
 */
@interface Nike : NSObject

//---------------------------------------------------------------------------------------
// Version Information
//---------------------------------------------------------------------------------------

/*! 
 Gets the version number for the current Nike SDK release.
 
 @result A string representing the Nike SDK version.
 */
+ (NSString *)version;

//--------------------------------------------------------------------------------------
// Logging
//---------------------------------------------------------------------------------------


/*! 
 Set the logging level for the Nike SDK. The default logger for the SDK is built on the 
 top of the Apple System Log. There is not call available to display current log level.
 
 @param level The maximum logging level that will be displayed.
 */
+ (void)setLogLevel:(NikeLogLevel)level;

//---------------------------------------------------------------------------------------
// Authorization Methods
//---------------------------------------------------------------------------------------


/*!
 Returns the current users credentials, or nil if they do not exist.
 
 @return NIKECredential
 */
+ (NIKECredential *)credential;


/*!
 Checks if there is a currently logged in user. This does not guarantee the ability to make 
 requests.
 
 @result YES if there is an active user, otherwise NO.
 */
+ (BOOL)isLoggedIn;

/*!
 Logs the user in via Safari. This initiates the login by creating a URL appropriate for authentication
 and opening it with [[UIApplication sharedApplication] openURL:]
 */
+ (void)login;

/*! 
 Logs out the current user.  
 */
+ (void)logOut;

//---------------------------------------------------------------------------------------
// Inter App URL
//---------------------------------------------------------------------------------------


/*!
 Identifies whether the URL can be handled by the SDK. If this method returns YES, a corresponding call to
 handleOpenURL: should be made.
 
 @param url URL to handle
 @param sourceApplication The bundle ID of the app that is requesting your app to open the URL (url).
 @param annotation A property-list object supplied by the source app to communicate information to the receiving app. 
 @warning Annotation is currently unused, and it's value is ignored
 @return YES if the SDK can handle the URL, no otherwise
 */
+ (BOOL)canHandleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/*!
 Handle a URL. Currently this call only handles authentication with Nike. It is intended to be called with the
 redirect URL after a user has authenticated with Nike. At that time, the SDK will make a secondary call to Nike
 to acquire an Access token. The token will then be stored, and made available for use. This message finishes with
 a NIKELoginStateChangedNotification or a NIKELoginErrorNotification.
 
 @param url The url passed to the application
 */
+ (void)handleOpenURL:(NSURL *)url;



@end
