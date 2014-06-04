//
//  NKTextureShader.m
//  NodeKittenExample
//
//  Created by Leif Shackelford on 2/24/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NKDrawDepthShader.h"
#import "NodeKitten.h"

@implementation NKDrawDepthShader;

- (instancetype)initWithNode:(NKNode *)node useColor:(NKByteColor*)nilForDefaultAttrib {
    self = [self initWithNode:node];
    if (self) {
        if (nilForDefaultAttrib) {
            _forceColor = nilForDefaultAttrib;
        }
        _useColor = true;
        _shouldInvert = false;
    }
    return self;
}

- (instancetype)initWithNode:(NKNode *)node {

    NSMutableString *vert = [[NSMutableString alloc]init];
    
    [vert appendString:nkVertexHeader];
    [vert appendString:@"\n\
     uniform mat4 modelViewMatrix;\n\
     uniform mat4 projectionMatrix;\n\
     uniform int use_color;\n\
     uniform int use_texture;\n\
     uniform int should_invert;\n\
     uniform vec4 force_color;\n\
     \n\
     varying vec4 position_varying;\n\
     varying vec4 color_varying;\n\
     varying vec4 texCoord_varying;\n\
     void main()\n\
     {\n\
     position_varying = projectionMatrix * modelViewMatrix * position;\n\
     if (use_color == 1){\n\
     color_varying = vec4(color.r, color.g,color.b,1.0);\n\
     }else{\n\
     color_varying = vec4(1.0);\n\
     }\n\
     if (use_texture == 1){\n\
     texCoord_varying = color;\n\
     }\n\
     gl_Position = projectionMatrix * modelViewMatrix * position;\n\
     }\n\
     "];
    
    NSMutableString *frag = [[NSMutableString alloc]init];
    
    [frag appendString:nkFragmentHeader];
    [frag appendString:@"\n\
     \n\
     uniform int should_invert;\n\
     varying vec4 position_varying;\n\
     varying vec2 textureCoordinate;\n\
     void main()\n\
     {\n\
     float depth;\n\
     if (should_invert == 1){\n\
     depth = (1. - ((position_varying.z / position_varying.w) + 1.0) * 0.5);\n\
     }\n\
     else depth = ((position_varying.z / position_varying.w) + 1.0) * 0.5;\n\
     //depth = depth*depth;\n\
     gl_FragColor = vec4(depth*color_varying.r, depth*color_varying.g, depth*color_varying.b, 1.0);\n\
     //gl_FragDepth​ = vec4(depth, depth, depth, 1.0);\n\
     //gl_FragColor = vec4(depth, depth, depth, 1.0) * texture2D(depthTexture, textureCoordinate);\n\
     //gl_FragColor = texture2D(depthTexture, textureCoordinate);\n\
     }\n\
     "];
    
    
    self = [super initWithVertexSource:vert fragmentSource:frag];
    
    if (self) {
        NSLog(@"init draw depth shader");
        _useColor = false;
        _shouldInvert = false;
    }
    
    return self;

}

-(void)begin {
    
//    if (self.usesFbo){
//        
//        if (!fbo){
//            
//            fbo = new NKVbo;
//            
//            NKVbo::Settings settings;
//            
//            settings.width = self.nodeRef.size.width;
//            settings.height = self.nodeRef.size.height;
//            settings.internalformat = GL_RGBA;
//            settings.numSamples = 0;
//            settings.useDepth = true;
//            settings.useStencil = true;
//            //settings.depthStencilAsTexture = true;
//            
//            fbo->allocate(settings);
//
//            NSLog(@"allocate fbo w: %1.0f h: %1.0f", fbo->getWidth(), fbo->getHeight());
//            texFill = new ofPlanePrimitive;
//            texFill->set(self.nodeRef.size.width,self.nodeRef.size.height);
//            texFill->resizeToTexture(fbo->getTextureReference());
//            texFill->setOrientation(V3Make(0,180,180));
//        }
//        
//        fbo->begin();
//        ofClear(0,0,0,255);
//        glPushMatrix();
//        //ofTranslate(self.nodeRef.size.width*.5, self.nodeRef.size.height*.5);
//        ofTranslate(fbo->getWidth() / 2., fbo->getHeight()/2.);
//        ofMultMatrix([self.nodeRef getGlobalTransformMatrix]);
//    }
//    
//    else {
//        shader->begin();
//        
//        if (_useColor || _forceColor) {
//            shader->setUniform1i("use_color", 1);
//            if (_forceColor) {
//                GLfloat col[4];
//                [_forceColor getRed:&col[0] green:&col[1] blue:&col[2] alpha:&col[3]];
//                shader->setUniform4f("force_color", col[0], col[1], col[2], col[3]);
//            }
//        }
//        if (_shouldInvert){
//            shader->setUniform1i("should_invert", 1);
//        }
//        
//        if (self.paramBlock){
//            self.paramBlock(shader, fbo);
//        }
//    }
    
}

-(void)end {
    
//    if (self.usesFbo) {
//        
//        glPopMatrix();
//        fbo->end();
//        
//        shader->begin();
//        
//        //shader->setUniformTexture("depthTexture", fbo->getDepthTexture(), 0);
//        
//        if (self.paramBlock){
//            self.paramBlock(shader, fbo);
//        }
//        
//        glPushMatrix();
//        
//        // INVERT TRANSFORM TO ORIENT PLANE AT CAMERA
//         ofMultMatrix([self.nodeRef getGlobalTransformMatrix].getInverse());
//        
//        // 1 // DRAW FBO
////        ofSetColor(255);
////        texFill->setOrientation(V3Make(0,180,0));
////        ofMultMatrix(self.nodeRef.node->getLocalTransformMatrix());
////        ofMultMatrix(texFill->getLocalTransformMatrix());
////        glRotatef(180., 0, 0, 1);
////        fbo->draw(-self.nodeRef.size.width*.5, -self.nodeRef.size.height*.5);
//        
//        // OR 2 // DRAW PLANE
//        ofMultMatrix(texFill->getLocalTransformMatrix());
//        
//        ofGetCurrentRenderer()->draw(*texFill, OF_MESH_FILL);
//        
//        // END FBO TRANSFORM
//        glPopMatrix();
//        
//    }
//    //    
//    shader->end();
    
    
    
}

@end
