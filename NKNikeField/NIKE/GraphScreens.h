//
//  GraphScreens.h
//  Nico
//
//  Created by Robby on 8/4/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NikeConnect.h"

@interface GraphScreens : UIView

{
    NSMutableDictionary *cachedImages;
}

@property (nonatomic, strong) NSString *date;
@property (nonatomic, weak) NikeConnect *nikeConnect;

-(void)update;
-(void)pan:(NSInteger)direction;
-(void)pinchIn;
-(void)pinchOut;
@end
