//
//  NikeConnect.h
//  Nico
//
//  Created by Robby on 7/9/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//
//
//  currently calibrated for FUEL band data sets, because that's all that has been available to me
//
// keys: dates (2013-07-25)
// objects: NSDictionary with keys @"fuel", @"calories", @"steps", @"activityId"

#import <Foundation/Foundation.h>
#import "Nike.h"
#import <sqlite3.h>
#import "AppDelegate.h"

@protocol NikeConnectDelegate <NSObject>
@optional
-(void)connectionSuccessful;
-(void)dataDidUpdate;
@end

@interface NikeConnect : NSObject <UIAlertViewDelegate, UITextFieldDelegate>

@property id <NikeConnectDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *calculations;
@property sqlite3 *database;

-(void)connect;
-(void)disconnect;
-(BOOL)isConnected;
-(void)loadAllPriorLogins;
-(void)request10Days;
-(void)requestCascadingDataOfMonths:(NSInteger)months;


@end