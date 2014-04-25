//
//  ViewController.h
//  Nico
//
//  Created by Robby on 7/1/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NikeConnect.h"

@class SKViewController;

@interface NikeViewController : UIViewController <NikeConnectDelegate>

@property (nonatomic, weak) SKViewController *delegate;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *backButton;

@end
