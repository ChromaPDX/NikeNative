//
//  GameStatsViewController.h
//  ChromaNSFW
//
//  Created by Leif Shackelford on 11/25/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game;

@interface GameStatsViewController : UITableViewController

@property (nonatomic, weak) Game *game;
@property (nonatomic, strong) NSDictionary *matchInfo;

- (id)initWithGame:(Game*)game style:(UITableViewStyle)style;


@end
