//
//  NKShaderNode.m
//  NodeKittenExample
//
//  Created by Leif Shackelford on 2/22/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKShaderNode




// ************* //
//     INIT      //
// ************* //
#pragma mark - INIT

-(instancetype)initWithNode:(NKNode *)node { // GENERAL INIT
    self = [super init];
    
    if (self){
        _nodeRef = node;
        _usesFbo = false;
        _needsDepthBuffer = false;
    }
    
    return self;
}

-(instancetype)initWithShaderNamed:(NSString*)name node:(NKNode*)node paramBlock:(ShaderParamBlock)block{
    
    self = [self initWithNode:node];
    
    if (self){
        [self loadShaderNamed:name paramBlock:block];
    }
    return self;
    
}

-(instancetype)initWithFragmentShaderNamed:(NSString *)name node:(NKNode*)node paramBlock:(ShaderParamBlock)block {
    
    self = [self initWithNode:node];
    
    if (self){
        [self loadFragmentShaderNamed:name paramBlock:block];
    }
    return self;
}

-(instancetype)initWithShaderFromString:(NSString *)glslStringConst node:(NKNode*)node paramBlock:(ShaderParamBlock)block {
    
    self = [self initWithNode:node];
    
    if (self){
        [self loadShaderFromString:glslStringConst paramBlock:block];
        
    }
    return self;
    
}

-(instancetype)initWithShaderStringArray:(NSArray *)array node:(NKNode*)node paramBlock:(ShaderParamBlock)block {
    
    self = [self initWithNode:node];
    
    if (self){
        [self loadShaderFromStringArray:array paramBlock:block];
    }
    
    return self;
    
}

// ************* //
//     LOAD      //
// ************* //
#pragma mark - LOAD

-(void)loadShaderNamed:(NSString *)name {
    [self loadShaderNamed:name paramBlock:nil];
}

-(void)loadShaderNamed:(NSString*)name paramBlock:(ShaderParamBlock)block {
    
//    if (!shader) {
//        shader = new ofShader;
//    }
//    if (shader->load(cppString([name stringByAppendingString:@".vert"]), cppString([name stringByAppendingString:@".frag"]))){
//        NSLog(@"successfully compiled shader: %@",name);
//        _paramBlock = block;
//    }
//    
//    else {
//        NSLog(@"failed to compile shader: %@",name);
//    }
}

- (void)loadFragmentShaderNamed:(NSString*)name paramBlock:(ShaderParamBlock)block{
    
    
//    if (!shader) {
//        shader = new ofShader;
//    }
//    if (shader->load(cppString([name stringByAppendingString:@".vert"]), cppString([name stringByAppendingString:@".frag"]))){
//        NSLog(@"successfully compiled shader: %@",name);
//        _paramBlock = block;
//    }
//    
//    else {
//        NSLog(@"failed to compile shader: %@",name);
//    }
    
}


-(void)loadShaderFromString:(NSString *)glslStringConst {
    [self loadShaderFromString:glslStringConst paramBlock:nil];
}

//// advanced use
//// these methods create and compile a shader from source or file
//// type: GL_VERTEX_SHADER, GL_FRAGMENT_SHADER, GL_GEOMETRY_SHADER_EXT etc.
//bool setupShaderFromSource(GLenum type, string source);
//bool setupShaderFromFile(GLenum type, string filename);
////
////

-(void)loadShaderFromString:(NSString *)glslStringConst paramBlock:(ShaderParamBlock)block {
    
//    if (!shader) {
//        shader = new ofShader;
//    }
//    
//    _paramBlock = block;
//    
//}
//
//-(void)loadShaderFromStringArray:(NSArray *)string paramBlock:(ShaderParamBlock)block {
//    if (!shader) {
//        shader = new ofShader;
//    }
//    
//    _paramBlock = block;
//    
//    if (string.count == 2) {
//        if (shader->setupShaderFromSource(GL_VERTEX_SHADER, cppString(string[0]))) {
//            if (GLLOG) {
//            NSLog(@"VERTEX SHADER SUCCESSFULLY LOADED FROM CODE");
//            NSLog(@"PGM \n%@", string[0]);
//            }
//            if (shader->setupShaderFromSource(GL_FRAGMENT_SHADER, cppString(string[1]))) {
//                if (GLLOG) {
//                NSLog(@"FRAGMENT SHADER SUCCESSFULLY LOADED FROM CODE");
//                NSLog(@"PGM \n%@", string[1]);
//                }
//                
//                shader->bindDefaults();
//                
//                if (shader->linkProgram()){
//                    if (GLLOG) {
//                    NSLog(@"V+F Program linked");
//                    }
//                }
//            }
//            else {
//                NSLog(@"BAD !!! PGM \n%@", string[1]);
//            }
//            
//        }
//        
//        
//    }
}

// ************* //
//      RUN      //
// ************* //

#pragma mark - RUN

-(void)begin {
//    if (_usesFbo){
//        if (!fbo){
//            fbo = new NKVbo;
//            fbo->allocate(_nodeRef.size.width, _nodeRef.size.height,GL_RGBA);
//            NSLog(@"allocate fbo w: %1.0f h: %1.0f", fbo->getWidth(), fbo->getHeight());
//            texFill = new ofPlanePrimitive;
//            texFill->set(_nodeRef.size.width,_nodeRef.size.height);
//            texFill->resizeToTexture(fbo->getTextureReference());
//            //texFill->setParent(*_nodeRef.node);
//            texFill->setOrientation(V3Make(0,180,180));
//        }
//        
//        fbo->begin();
//        ofClear(0,0,0,255);
//        glPushMatrix();
//        ofTranslate(fbo->getWidth() / 2., fbo->getHeight()/2.);
//        
//    }
//    else {
//        shader->begin();
//        if (_paramBlock){
//            _paramBlock(shader, nil);
//        }
//    }
}

-(void)end {
//    if (_usesFbo){
//        glPopMatrix();
//        fbo->end();
//
//        shader->begin();
//        
//        if (_paramBlock){
//            _paramBlock(shader, fbo);
//        }
//
//        //fbo->draw([_nodeRef getDrawFrame]);
//        
//        //texFill->draw();
//        
//        glPushMatrix();
//        ofMultMatrix(texFill->getLocalTransformMatrix());
//        ofGetCurrentRenderer()->draw(*texFill, OF_MESH_FILL);
//        glPopMatrix();
//        
//        shader->end();
//
//       
//    }
//    
//    else {
//        shader->end();
//    }
}



@end
