//
//  MetaController.h
//  ChromaNSFW
//
//  Created by Chroma Developer on 1/15/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ModelHeaders.h"
#import "PAPConstants.h"
#import "PAPCache.h"
#import "PAPUtility.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/UTCoreTypes.h>
#endif

#define FUEL_DATA_KEY @"fuelData"

@protocol ParseControllerDelegate <NSObject>

@optional
-(void)presentMetaViewController;

@end

@protocol ParseControllerImageListener <NSObject>

-(void)ParseLoadedImage:(UIImage*)image;

@end

@interface ParseController : NSObject


{
    id <ParseControllerDelegate> delegate;
    BOOL firstLaunch;
    
    dispatch_queue_t saveThread;
    
}

+ (void)addPlayer:(PFUser*)player;
+ (ParseController *)sharedInstance;
+ (void) save;

+(void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error;
+(BOOL)loadParseWithViewController:(id <ParseControllerDelegate>)controller;
+(void)cacheToUserDefaults;

+(UIImage*)imageForPlayer:(NSString *)username withListener:(NSObject<ParseControllerImageListener>*)listener;
+(NSDictionary*)cachedPlayerForMe;

+(void)addFuel:(PFObject*)fuel toPlayer:(PFUser*)player;

-(NSMutableDictionary*)playerCache;
-(NSMutableDictionary*)imageCache;


- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;
- (void)addFuelDataToUser:(NSDictionary *)entry forKey:(NSString*)key;

@property (nonatomic, weak) NSObject <ParseControllerImageListener> *listener;

@property (nonatomic, strong) NSMutableDictionary *playerCache;
@property (nonatomic, strong) NSMutableDictionary *imageCache;

@property (nonatomic, weak) id <ParseControllerDelegate> delegate;
@property (nonatomic) int networkStatus;

#if TARGET_OS_IPHONE
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
#endif

//@property (nonatomic, strong) NSMutableDictionary *textures;

@end