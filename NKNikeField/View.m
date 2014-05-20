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
#import "Menus.h"

@implementation View

- (id) initWithCoder:(NSCoder*)coder
{
    
    if ((self = [super initWithCoder:coder]))
    {

        
  
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.scene) {
        float scale = [[UIScreen mainScreen] scale];
        
        self.scene = [[MainMenu alloc]initWithSize:S2Make(self.frame.size.width*scale, self.frame.size.height*scale)];
        
        NSLog(@"VIEW HEIGHT, %f", self.frame.size.height);
        
        [self startAnimation];
    }
    
}



@end
