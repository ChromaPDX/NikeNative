//
//  AlertSprite.m
//  ChromaNSFW
//
//  Created by Chroma Developer on 12/10/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import "AlertSprite.h"

@implementation AlertSprite

-(instancetype)initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size    {
    
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate alertDidCancel];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
@end
