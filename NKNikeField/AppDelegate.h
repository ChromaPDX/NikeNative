//
//  AppDelegate.h
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class PAPWelcomeViewController;
@class MetaViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, PFLogInViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end
