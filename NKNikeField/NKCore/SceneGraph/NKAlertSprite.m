//
//  AlertSprite.m
//  ChromaNSFW
//
//  Created by Chroma Developer on 12/10/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import "NKAlertSprite.h"

@implementation NKAlertSprite

-(instancetype)initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(S2t)size    {
    
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
    
}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
     [_delegate alertDidCancel];
    return false;
}

@end
