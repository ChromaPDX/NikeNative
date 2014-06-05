//
//  NIKEStandardRequest.h
//  SDK
//
//  Created by Hooge, Matthew on 1/22/14.
//  Copyright (c) 2014 Nike, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIKERequest.h"

/*!
 The NIKEStandardRequest class contains methods that create NIKERequest 's that cover the most common
 functionality available from the Nike+ API. All requests return JSON data on success. Authentication for 
 these requests is handled by combining these requests with a NIKECredential. For further explanation on 
 the data returned by these reqeusts, see the Nike+ API documentation.
 */

@class NIKEEnvironment;
@interface NIKEStandardRequest : NSObject


///---------------------------------------------------------------------------------------
/// @name OAuth Authorization Code Grant
///---------------------------------------------------------------------------------------

/*!
 A request used for an inter-app call with the Safari app through the UIApplication
 openURL method. The given state parameter is used for authentication. See the OAuth2.0
 RFC for more information. The URL from this request is passed to the UIApplication openURL
 method.
 
 Example of generating UUID for use as state variable.
 
    NSString *state = [[[NSUUID alloc] init] UUIDString];
    NIKERequest *request = [NIKEStandardRequest getAuthorizationRequestWithState:state 
                                                                     environment:[NIKEEnvironment defaultEnvironment]];
    [[UIApplication sharedApplication] openURL:request.mutableURLRequest.URL];
 
 @param state A state string used in the authentication flow.
 @param environment Nike environment object configured with the correct Nike app information.
 @return A NIKERequest object with a URL suitable for an inter-app launch.
 @exception NSInternalInconsistencyException if the registered scheme is not configured in the Info.plist or the
 client id is not configured in the Info.plist
 */
+ (NIKERequest *)getAuthorizationRequestWithState:(NSString *)state
                                      environment:(NIKEEnvironment *)environment;

/*!
 A request used to exchange an authorization code for an access token, refresh token, and
 user id. The interAppURL is the redirect URL plus the authorization code. The expected state
 should match the state used in the Authorization request. See getAuthorizationRequestWithState.
 
 Example of handling the inter-app callback
 
     - (BOOL)application:(UIApplication *)application
                 openURL:(NSURL *)url
       sourceApplication:(NSString *)sourceApplication
              annotation:(id)annotation {
         NSError *error;
         NSString *state = [[NSUserDefaults standardUserDefaults] stringForKey:SavedStateKey];

         if (error) {
         // Handle error
         }
         // Make request over network
     }

 @param interAppURL URL recieved in the `application:openURL:sourceApplication:annotation:` delegate
 callback
 @param environment NIKEEnvironment. Default environment is provided by calling [NIKEEnvironment defaultEnvironment]
 @param expectedState State used in the inital Authorization Code request
 @return NIKERequest configured to retrieve an Access Token from the Nike+ API
 @exception NSInternalInconsistencyException if interAppURL or environment are nil
 */
+ (NIKERequest *)getAccessTokenRequestWithURL:(NSURL *)interAppURL
                                  environment:(NIKEEnvironment *)environment
                                expectedState:(NSString *)state
                                        error:(NSError *__autoreleasing*)error;


///---------------------------------------------------------------------------------------
/// @name OAuth Refresh Token
///---------------------------------------------------------------------------------------

/*!
 Creates a refresh token request given the existing credentials.
 
    NIKERequest *request = [NIKEStandardRequest getRefreshTokenRequestWithCredential:[Nike credential]];
 
 @param credential Current, expired, Nike credentials
 @return NIKERequest configured to retrieve an updated token
 @exception NSInternalInconsistencyException if credential is nil
 */
+ (NIKERequest *)getRefreshTokenRequestWithCredential:(NIKECredential *)credential;


///---------------------------------------------------------------------------------------
/// @name Nike Aggregate Data
///---------------------------------------------------------------------------------------

/*!
 Create a request to retrieve aggregate sport data. The aggregation of user data is divided by
 experience type, and then further subdivided by record types. Please refer to the
 Aggregate Sport Data for a detailed explanation of the JSON return values.
 
 @return NIKERequest configured for an aggregate data reqeust.
 */
+ (NIKERequest *)getAggregateSportDataRequest;


///---------------------------------------------------------------------------------------
/// @name Nike List Activities
///---------------------------------------------------------------------------------------

/*!
 Retrieve a list of a users most recent activities.

 @return NIKERequest configured for a list activities request
 */
+ (NIKERequest *)getListActivities;

/*!
 Request for a list of activities within a certain time frame. The time frame is controlled with
 the start and end dates. Count and offset are used for pagination of results. Offset begins at 1,
 default count is 5
 
 For example, if a list of activities is expected to contain 1000 entries, and you want to get entries
 100 - 200
 
     NSDate *oneMonthAgo = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days in seconds
     NIKERequest *request = [NIKEStandardRequest getListActivitiesWithStart:oneMonthAgo
                                                                        end:[NSDate date]
                                                                     offset:@100
                                                                      count:@100];
 @param state Start date
 @param end End date
 @param offset Number to offset from the start of the list (starts at 1)
 @param count Number of activities required for the request (default 5)
 @return Request configured with the given parameters
 */
+ (NIKERequest *)getListActivitiesWithStart:(NSDate *)start
                                        end:(NSDate *)end
                                     offset:(NSNumber *)offset
                                      count:(NSNumber *)count;

/*!
 Create a next page request based on a previous response from a list activities request. This can be used
 to get the next set of results. 
 Example request:
    
     NIKERequest *request = // Nike request for activities that has multiple pages
     request.credential = [Nike credential];
     NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request.mutableURLRequest
                                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            // Handle JSON error
        }
        NIKERequest *nextPage = [NIKEStandardRequest getListActivitiesForPage:(NSDictionary *)json];
        // Schedule the request for the next page.
     }];
 
 @param JSONResponseData Data from a previous request, the structure of which matches a JSON object returned from the 
    Nike+ API.
 @return NIKERequest configured to retrieve the next page.
 @exception NSInternaInconsistencyException if JSONResponseData is nil
     
 */
+ (NIKERequest *)getListActivitiesForPage:(NSDictionary *)JSONResponseData;


///---------------------------------------------------------------------------------------
/// @name Activity Detail
///---------------------------------------------------------------------------------------

/*!
 Get the detailed data for the given activity id. The activity id must exist on the server.
 
 @param activityId Id of an activity on Nike+
 @return NIKERequest configured to get details of an activity.
 @exception NSInternalInconsistencyException if activityId is nil
 */
+ (NIKERequest *)getActivityDetailFor:(NSString *)activityId;


///---------------------------------------------------------------------------------------
/// @name Post Activity
///---------------------------------------------------------------------------------------

/*!
 Post an activity to a users account. See Nike+ API documentation for the most recent documentation.
 This request requires a JSON body with the proper format.
 
     id activityData; // Object with correct values, see Nike+ API documentation
     
     NIKERequest *request = [NIKEStandardRequest postActivity];
     request.credential = [Nike credential];
     
     NSError *jsonError;
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:activityData options:0 error:&jsonError];
     if (!jsonError) {
     request.HTTPBody = jsonData;
     // Post request to Nike+ API
     }
 
 @warning Posting an activity is still under development, watch Nike+ API documentation for details
 @return NIKERequest
 */
+ (NIKERequest *)postActivity;


///---------------------------------------------------------------------------------------
/// @name GPS Activity Data
///---------------------------------------------------------------------------------------

/*!
 Retrieve GPS activity data for the given activity. 
 See Nike+ API for structure of expected JSON response
 
 @param activityId Id for the activity associated with the GPS data requried
 @exception NSInternalInconsistencyException if activityId is nil
 */
+ (NIKERequest *)getGPSActivityDataFor:(NSString *)activityId;

///---------------------------------------------------------------------------------------
/// @name Date Format
///---------------------------------------------------------------------------------------

/*!
 Date formatter that converts an NSDate into an ISO8601 compliant Year Month Day string in
 the format `yyyy-MM-dd`.
 @return NSDateFormatter set up for conversion
 */
+ (NSDateFormatter *)ISO8601YearMonthDayFormatter;

@end
