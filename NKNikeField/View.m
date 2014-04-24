//
//  View.m
//  NKNative
//
//  Created by Chroma Developer on 4/4/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "View.h"
#import "DevMenu.h"
#import "GameScene.h"

@implementation View

- (id) initWithCoder:(NSCoder*)coder
{
    
    if ((self = [super initWithCoder:coder]))
    {
        // Initialization code
        float scale = [[UIScreen mainScreen] scale];
        
        self.scene = [[DevMenu alloc]initWithSize:CGSizeMake(self.frame.size.width*scale, self.frame.size.height*scale)];
        //GameScene *scene = [[GameScene alloc]initWithSize:CGSizeMake(self.frame.size.width*scale, self.frame.size.height*scale)];
        //self.scene = scene;
        
        //[[scene game] startAIGame];
        
        self.scene.nkView = self;
      
        //self.animationInterval = 1.0 / 60.;
        
        [self startAnimation];
        
    }
    return self;
}


@end
