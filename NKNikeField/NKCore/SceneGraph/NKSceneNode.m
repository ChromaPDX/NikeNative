//
//  NKSceneNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/17/14.
//
//

#import "NodeKitten.h"

@implementation NKSceneNode


-(instancetype)initWithSize:(CGSize)size {
    
    self = [super init];
    
    if (self){
        
        self.size = size;
        self.name = @"SCENE";
        [self logCoords];
        
        self.backgroundColor = [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1.];
        self.shouldRasterize = false;
        useShader = false;
        self.userInteractionEnabled = true;
        self.blendMode = -1;
        self.cullFace = -1;
        
        _camera = [[NKCamera alloc]initWithScene:self];

        localTransformMatrix = M16IdentityMake();
        
        self.scene = self;
        
    }
    
    return self;
}

-(void)updateWithTimeSinceLast:(F1t)dt {
    fps = (int)(1000./dt);
    
    [_camera updateWithTimeSinceLast:dt];
    [NKSoundManager updateWithTimeSinceLast:dt];
    
    [super updateWithTimeSinceLast:dt];
}


-(void)draw {

    if (_backgroundColor) {
        C4t c;
        [_backgroundColor getRed:&c.r green:&c.g blue:&c.b alpha:&c.a];
        glClearColor(c.r, c.g, c.b, c.a);
    }
    if (!self.parent) {
        
        [_camera begin];

       
    }

    [super draw];

    
    if (!self.parent) {
        [_camera end];
    }
    
    // UNCOMMENT TO DEBUG / DRAW DEPTH BUFFER
//    if (self.depthFbo){
//        // NSLog(@"draw depth fbo");
//        ofClear(0, 0, 0, 255);
//        glPushMatrix();
//        ofSetColor(255);
//        //ofTranslate(self.size.width*.5, self.size.height*.5);
//        //ofMultMatrix(self.node->getGlobalTransformMatrix().getInverse());
//        self.depthFbo->draw(0,0);
//        glPopMatrix();
//        
//    }
    
}
    


//-(void)end {
//    
//    if (!self.isHidden && (!_shouldRasterize || (_shouldRasterize && dirty)))
//    {
//        
//        if (useShader){
//            [self.shader end];
//        }
//        
//        if (_shouldRasterize) {
//            
//            if (!self.parent) {
//                [_camera end];
//            }
//            
//            fbo->end();
//            dirty = false;
//            
//        }
//        
//        else {
//            glPopMatrix();
//            //self.node->restoreTransformGL();
//            
//            if (!self.parent) {
//                [_camera end];
//            }
//         
//        }
//        
//    }
//    
//    else if (_shouldRasterize && !dirty) {
//        
//        R4t d = [self getDrawFrame];
//        
//        glPushMatrix();
//        ofMultMatrix( self.node->getLocalTransformMatrix() );
//        
//        fbo->draw(d.x, d.y);
//        
//        glPopMatrix();
//    }
//    
//    if  (debugUI){
//        string stats = "nodes :" + ofToString([self numNodes]) + " draws: " + ofToString([self numVisibleNodes]) + " fps: " + ofToString(fps);
//        ofDrawBitmapStringHighlight(stats, V3Makeself.size.width - 230, self.size.height - 7, _camera.get3dPosition.z));
//    }
//    
//    
//}


-(int)touchDown:(CGPoint)location id:(int)touchId {

    CGPoint p = [_camera screenToWorld:location];
    
    return [super touchDown:p id:touchId];
}
//
-(int)touchMoved:(CGPoint)location id:(int)touchId {
    CGPoint p = [_camera screenToWorld:location];
    
    return [super touchMoved:p id:touchId];
}
//
-(int)touchUp:(CGPoint)location id:(int)touchId {

    CGPoint p = [_camera screenToWorld:location];
    
    NSLog(@"touch : %f %f", p.x, p.y);
    
    return [super touchUp:p id:touchId];
}
//


@end
