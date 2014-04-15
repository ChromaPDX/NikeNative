//
//  View.m
//  NKNative
//
//  Created by Chroma Developer on 4/4/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "View.h"
#import "Scene.h"

@implementation View

- (id) initWithCoder:(NSCoder*)coder
{
    
    if ((self = [super initWithCoder:coder]))
    {
        // Initialization code
        
        self.scene = [[Scene alloc]initWithSize:CGSizeMake(self.frame.size.width*2., self.frame.size.height*2.)];
        self.scene.nkView = self;
        
        self.animationInterval = 1.0 / 60.;
        
        [self startAnimation];
        
    }
    return self;
}


@end
