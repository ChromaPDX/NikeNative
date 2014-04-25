//
//  NIKECredential.h
//
//  Copyright (c) 2013 Nike. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Posted when the currently authorized user's credentials change.
 */
extern NSString *const NIKECredentialDidChangeNotification;

/*! The key used to store the previous user's identifier value in a credential change notification.
 */
extern NSString *const NIKECredentialPreviousUserIdKey;

/*! The type of credential change, a NIKECredentialChangeType identifier.
 */
extern NSString *const NIKECredentialChangeTypeKey;

/*! YES if the SDK detects that the credential has been changed externally (e.g. while the app was in the
 background), otherwise NO.
 */
extern NSString *const NIKECredentialChangeWasExternalKey;

/*! Describes the changes that may take place to a user's credential.
 */
typedef enum
{
    NIKECredentialChangeTypeUnknown = 0,
    NIKECredentialChangeTypeUserChanged,
    NIKECredentialChangeTypeUserLoggedIn,
    NIKECredentialChangeTypeUserLoggedOut
}
NIKECredentialChangeType;

/*! Describes a user's Nike identifier, and access and refresh tokens. To observe changes to the currently authorized
 user, register for the NIKECredential notifications listed.
 */
@interface NIKECredential : NSObject

/*! The user's Nike platform identifier. You should regard this identifier as opaque - do not rely on its format or
 composition to distinguish Nike users.
 */
@property (nonatomic, readonly) NSString *userId;

/*! The user's OAuth 2.0 access token.
 */
@property (nonatomic, readonly) NSString *accessToken;

/*! The user's OAuth 2.0 refresh token.
 */
@property (nonatomic, readonly) NSString *refreshToken;

@end
