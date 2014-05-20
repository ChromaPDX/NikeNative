//
//  MetaController.cpp
//  ChromaNSFW
//
//  Created by Chroma Developer on 1/15/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#include "ParseController.h"
#include "AppDelegate.h"

#import "Reachability.h"

#import "PAPCache.h"
#import "PAPUtility.h"
#import "PAPConstants.h"

#import "PAPLogInViewController.h"

/// FUEL LOGIN
// KmikeyM@KMikeyM.com
// 6hy8APkpo
///

@interface ParseController ()
{
     NSMutableData *_data;
}
   // @property (nonatomic, strong) MBProgressHUD *hud;
    @property (nonatomic, strong) NSTimer *autoFollowTimer;
    
    @property (nonatomic, strong) Reachability *hostReach;
    @property (nonatomic, strong) Reachability *internetReach;
    @property (nonatomic, strong) Reachability *wifiReach;

@end

@implementation ParseController

static ParseController *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        //_textures = [NSMutableDictionary dictionary];
        //_data = [[NSMutableData alloc] init];
        
    }
    return self;
}


+ (ParseController *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}



-(NSMutableDictionary*)playerCache {
    
    if (!_playerCache) {
      
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[ParseController documentsDirectory] stringByAppendingString:@"playerCache.plist"]]){
           
            _playerCache = [[NSMutableDictionary alloc] initWithContentsOfFile:[[ParseController documentsDirectory] stringByAppendingString:@"playerCache.plist"]];
             NSLog(@"getting cache from local file : %@", _playerCache);
        }
        else {
            NSLog(@"Generate NEW player cache");
            _playerCache = [[NSMutableDictionary alloc]init];
        }

    }
  
   
    return _playerCache;
    
}

-(NSMutableDictionary*)imageCache {
    
    
    if (!_imageCache) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[ParseController documentsDirectory] stringByAppendingString:@"imageCache.plist"]]){
        
            _imageCache = [[NSMutableDictionary alloc] initWithContentsOfFile:[[ParseController documentsDirectory] stringByAppendingString:@"imageCache.plist"]];
                NSLog(@"getting image cache from local file %@", _imageCache);
        }
        
        if (!_imageCache) {
            NSLog(@"Generate NEW IMAGE cache");
            _imageCache = [[NSMutableDictionary alloc]init];
        }
        
    }
    

    
    //sharedObject.imageCache = imageCache;
    
    return _imageCache;
    
}

+(BOOL)loadParseWithViewController:(UIViewController*)controller {
    
    ParseController *shared = [ParseController sharedInstance];
    
    [shared setDelegate:controller];
    [shared monitorReachability];
    
    
    if (![PFUser currentUser]) {
        NSLog(@"presenting login controller");
        PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] init];
        [loginViewController setDelegate:self];
        loginViewController.fields = PFLogInFieldsFacebook;
        loginViewController.facebookPermissions = @[ @"user_about_me" ];
        
        
        [controller presentViewController:loginViewController animated:NO completion:^{
            
        }];

        // NSLog(@"presenting login controller");
        
        return 0;
    }
    
    NSLog(@"Parse User : %@ : is logged in", [[PFUser currentUser] username]);
    
    
    // Present Anypic UI
    // [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    
    
    [[PFUser currentUser] refreshInBackgroundWithTarget:shared selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
    
    return 1;
    
}


-(void)addFuelDataToUser:(NSDictionary *)entry forKey:(NSString*)key{

    NSLog(@"uploading fuel entry");
    
    // NSLog(@"adding fuel event: %@", data);

    PFObject *fuelEntry = [PFObject objectWithClassName:@"FuelData"];
    
    [fuelEntry setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [fuelEntry setObject:entry forKey:@"data"];
    [fuelEntry setObject:key forKey:@"timeStamp"];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *fuelACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [fuelACL setPublicReadAccess:YES];
    fuelEntry.ACL = fuelACL;

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // save
    [fuelEntry saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"added fuel object");
            
            
            //[[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            //            if (userInfo) {
            //                NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
            //
            //                if (commentText && commentText.length != 0) {
            //                    // create and save photo caption
            //                    PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
            //                    [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
            //                    [comment setObject:photo forKey:kPAPActivityPhotoKey];
            //                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
            //                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
            //                    [comment setObject:commentText forKey:kPAPActivityContentKey];
            //
            //                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            //                    [ACL setPublicReadAccess:YES];
            //                    comment.ACL = ACL;
            //
            //                    [comment saveEventually];
            //                    [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
            //                }
            //            }
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            NSLog(@"FuelData failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't sync fuel entry" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    
}


//+(void)cacheToUserDefaults {
//    NSLog(@"SAVING PLAYER CACHE !!");
//    
//    [[NSUserDefaults standardUserDefaults] setObject:[ParseController playerCache] forKey:@"PlayerCache"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//}

+(void)addPlayer:(PFUser*)player{
    
    NSMutableDictionary *shared = [ParseController sharedInstance].playerCache;
    
    NSMutableDictionary *playerBase = [shared[player.username] mutableCopy];
    
    if (!playerBase) {
        playerBase = [[NSMutableDictionary alloc] init];
    }
    
    [playerBase setObject:player.username forKey:@"username"];
    [playerBase setObject:player[@"facebookId"] forKey:@"facebookId"];
    [playerBase setObject:player[@"displayName"] forKey:@"name"];
    if (player[@"profile"]) {
        [playerBase setObject:player[@"profile"][@"pictureURL"] forKey:@"pictureURL"];
    }
    
    
    [shared setObject:playerBase forKey:player.username];
    
}

+(void)addFuel:(PFObject*)fuel toPlayer:(PFUser*)player{
    
    NSMutableDictionary *playerBase = [[ParseController sharedInstance].playerCache[player.username] mutableCopy];
    
    if (!playerBase) {
        NSLog(@"no player for fuel obect");
        return;
    }
    
    NSMutableDictionary *fuelBase = [playerBase[FUEL_DATA_KEY] mutableCopy];
    
    if (!fuelBase) {
   
        fuelBase = [[NSMutableDictionary alloc] init];
    }
    
    [fuelBase setObject:fuel forKey:fuel[@"timeStamp"]];
    
    [playerBase setObject:fuelBase forKey:FUEL_DATA_KEY];
    
    
}

+(NSDictionary*)cachedPlayerForMe {
    
    for (NSDictionary *p in [[ParseController sharedInstance].playerCache allValues]) {
        
        if ([[p valueForKey:@"username"] isEqualToString:[[PFUser currentUser] username]]) {
            return p;
        }
    }
    
    NSLog(@"player object not found in cache");
    return nil;
    
}

+(UIImage*)imageForPlayer:(NSString *)username withListener:(NSObject <ParseControllerImageListener>*)listener {

    
    if (![ParseController sharedInstance].imageCache[username]) {
        
        NSDictionary *user = [ParseController sharedInstance].playerCache[username];
        
        if (!user) {
            NSLog(@"no user for image request");
            return nil;
            
        }
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:user[@"pictureURL"]]];
            
            if ( data != nil ){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    
                    UIImage *image = [UIImage imageWithData:data];
                    
                    [[ParseController sharedInstance].imageCache setObject:data forKey:username];
                    
                    NSLog(@"adding image to cache: %@", [ParseController sharedInstance].imageCache);
                    
                    // _profiles[userData[@"name"]][@"image"] = [UIImage imageWithData: data];
                    
                    NSLog(@"downloaded image for %@ calling back to : %@", username, listener);
                    
                    [listener ParseLoadedImage:image];
                    
                    [sharedObject saveInBackground];
                });
                
            }
            
        });
        
        NSLog(@"no cached image for %@, downloading",  user[@"name"]);
        
        return nil;
        
    }
    
    return [UIImage imageWithData:[ParseController sharedInstance].imageCache[username]];
    
    //return sharedObject.imageCache[username];
    
    //return [[ParseController imageCache] valueForKey:username];
    
}


#pragma mark - REACHABILITY

- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName:@"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
    
    
}

- (void)reachabilityChanged:(NSNotification* )note {
    
    Reachability *curReach = (Reachability *)[note object];
    
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    _networkStatus = [curReach currentReachabilityStatus];
    
    if (_networkStatus == NotReachable) {
        NSLog(@"Network not reachable.");
    }
    
    
}

- (BOOL)isParseReachable {
    return _networkStatus != NotReachable;
}

#pragma mark - NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [PAPUtility processFacebookProfilePictureData:_data];
}

#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    [(UIViewController*)delegate dismissViewControllerAnimated:YES completion:^{
        
        // user has logged in - we need to fetch all of their Facebook data before we let them in
        if (![self shouldProceedToMainInterface:user]) {
            //self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
           // self.hud.labelText = NSLocalizedString(@"Loading", nil);
           // self.hud.dimBackground = YES;
        }
        
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
        
        
    }];
    
}




#pragma mark - ()

-(void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [self logOut];
        return;
    }
    
    // Check if user is missing a Facebook ID
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        
        [[FBRequest requestForMe]
         startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
         {
             
             // handle response
             if (!error) {
                 // Parse the data received
                 NSDictionary *userData = (NSDictionary *)result;
                 
                 NSString *facebookID = userData[@"id"];
                 
                 NSLog(@"MY FB ID: %@", facebookID);
                 
                 NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                 
                 NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                 
                 if (facebookID) {
                     userProfile[@"facebookId"] = facebookID;
                 }
                 
                 if (userData[@"name"]) {
                     
                     userProfile[@"name"] = userData[@"name"];
                     
                 }
                 
                 
                 if ([pictureURL absoluteString]) {
                     userProfile[@"pictureURL"] = [pictureURL absoluteString];
                 }
                 
                 [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                 [[PFUser currentUser] saveInBackground];
             }
             
                 
         }];
        
        //  [self SendFilteredRequest:0];
        
    

        // refresh Facebook friends on each launch
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
      
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
        
        // Refresh friend data
        
        [self refreshFriends];
        
    } else {
        NSLog(@"Current user is missing their Facebook ID");
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
               [self facebookRequestDidLoad:result];
                
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

-(void)refreshFriends {
    
    PFQuery *facebookFriendsQuery = [PFUser query];
    [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:[[PAPCache sharedCache] facebookFriends]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:facebookFriendsQuery, nil]];
    
    NSError *error = nil;
    
    NSArray *fuelFriends = [[query findObjects:&error] arrayByAddingObject:[PFUser currentUser]];
    
    if (!error) {
        
        for (PFUser *u in fuelFriends) {
            
            [ParseController addPlayer:u];

            PFQuery *query2 = [PFQuery queryWithClassName:@"FuelData"];
            [query2 whereKey:@"user" equalTo:u];
       
            
            //- (void)findObjectsInBackgroundWithBlock:(PFArrayResultBlock)block;
            [query2 findObjectsInBackgroundWithBlock:^(NSArray *activity, NSError *error) {
                
                for (PFObject *entry in activity) {
                    
                    //NSLog(@"player has fuel entry: %@", entry[@"timeStamp"]);
                    
                    [ParseController addFuel:entry toPlayer:u];
                    
                    //[[ParseController playerCache][u.username] setObject:entry forKey:entry[@"timeStamp"]];
                    
                }
              
                // Do something with the returned PFObject in the gameScore variable.
                // NSLog(@"%@", gameScore);
                
            }];
            
            NSLog(@"refresh friends: %@", u[@"displayName"]);
            
            [self saveInBackground];
            
            
        }
        
        
        // CREATE JOIN OBJECT
        
        
   

        
    }
    
    else {
        NSLog(@"error refreshing friends");
    }
    
    

    
   // [query2 whereKey:@"user" containedIn:[[PAPCache sharedCache] facebookFriends]];

    
    
}

+(NSString*)documentsDirectory {
    
    
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSLog(@"Documents Directory Contents: %@",[fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil]);

    return documentsDirectory;
    
}

- (void) saveInBackground {
    
    if (!saveThread) {
        saveThread = dispatch_queue_create("parseControllerSave", 0);
        
        
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, saveThread, ^(void){
            [ParseController save];
            saveThread = nil;
        });
        
        
    }

    
}

+ (void) save {

    NSLog(@"writing cache to %@", [[ParseController documentsDirectory] stringByAppendingString:@"playerCache.plist"]);
    
    [sharedObject.playerCache writeToFile:[[ParseController documentsDirectory] stringByAppendingString:@"playerCache.plist"] atomically:YES];
    
    NSLog(@"writing image cache to %@", [[ParseController documentsDirectory] stringByAppendingString:@"imageCache.plist"]);
    
    [sharedObject.imageCache writeToFile:[[ParseController documentsDirectory] stringByAppendingString:@"imageCache.plist"] atomically:YES];
    
   // NSLog(@"%@", _playerCache);
    
}

- (void)facebookRequestDidLoad:(id)result {
    
    //NSLog(@"facebook request did load");
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
                //NSLog(@"friend:%@", friendData);
            }
        }
        
        // cache friend data
        [[PAPCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
               // self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                NSLog(@"firstLaunch");
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Anypic
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                PFQuery *autoFollowAccountsQuery = [PFUser query];
                [autoFollowAccountsQuery whereKey:kPAPUserFacebookIDKey containedIn:kPAPAutoFollowAccountFacebookIds];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:autoFollowAccountsQuery,facebookFriendsQuery, nil]];
                
                NSArray *anypicFriends = [query findObjects:&error];
                
                if (!error) {
                    
                    // CREATE JOIN OBJECT
                    
                    [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                        [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    //[MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:NO];
                    if (anypicFriends.count > 0) {
//                        self.hud = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:NO];
//                        self.hud.dimBackground = YES;
//                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                    } else {
                        // [self.homeViewController loadObjects];
                        NSLog(@"suposed to load objects");
                    }
                }
            }
            
            else {
                if (![self shouldProceedToMainInterface:user]) {
                    
                    [self logOut];
                    return;
                }
                
            }
            
            [user saveEventually];
            
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        NSLog(@"Creating Profile");
       // self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

- (void)logOut {
    NSLog(@"logging out of PF / FB");
    // clear cache
    [[PAPCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    //    [self.navController popToRootViewControllerAnimated:NO];
    
    //#warning PRESENT LOGIN HERE
    //[self presentLoginViewController];
    //
    //    self.homeViewController = nil;
    //    self.activityViewController = nil;
}


- (void)autoFollowTimerFired:(NSTimer *)aTimer {
   // [MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:YES];
    //[MBProgressHUD hideHUDForView:self.welcomeViewController.view animated:YES];
    //[self.homeViewController loadObjects];
    
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        
       // [MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:YES];
        //[self presentTabBarController];
        
        //[self.navController dismissModalViewControllerAnimated:YES];
        
        
        
        if ([delegate respondsToSelector:@selector(presentMetaViewController)]) {
               [delegate presentMetaViewController];
        }
     
        
        NSLog(@"proceed to main interface");
        
        return YES;
    }
    
    // NSLog(@"proceed to main interface");
    
    return NO;
    
}

@end