//
//  NikeBaseScene.m
//  NKNikeField
//
//  Created by Leif Shackelford on 6/3/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NikeBaseScene.h"

@implementation NikeBaseScene

-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    
    if (self) {
        
        
        self.camera.nearZ = 10;
        self.camera.farZ = 2000;
        [self.camera setPosition3d:V3Make(0, 0, self.scene.size.height)];
#if NK_USE_GLES
        if (self.scene.size.height == 1136) {
            self.camera.fovVertRadians = DEGREES_TO_RADIANS(53);
        }
        else {
            self.camera.fovVertRadians = DEGREES_TO_RADIANS(54);
        }
#else
        self.fovVertRadians = DEGREES_TO_RADIANS(54);
#endif
        
    }
    return self;
}


@end
