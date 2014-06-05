//
//  ONEAccountCredential.h
//  OnePlusSDK
//
//  Created by Nike on 09/11/2011.
//  Copyright (c) 2011 Nike, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Describes a user account credential provided by the Nike platform authentication service.
 */
@interface NIKECredential : NSObject

@property (nonatomic, readonly, copy) NSString *accessToken;
@property (nonatomic, readonly, copy) NSString *refreshToken;
@property (nonatomic, readonly, copy) NSString *userId;

/*! Creates a credential instance using the supplied access token, refresh token, and user identifier.
 
 @param accessToken An access token (required).
 @param refreshToken A refresh token (required).
 @param userIdentifier A Nike platform user identifier (required).
 
 @result An initialized credential instance or nil.
 */
- (id)initWithOAuthAccessToken:(NSString *)token refreshToken:(NSString *)refreshToken userId:(NSString *)userId;


@end
