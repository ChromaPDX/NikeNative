//
//  NKMeshNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//

#import "NodeKitten.h"


@implementation NKMeshNode

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size {
    
    self = [super initWithSize:size];
    if (self) {
        self.size3d = size;
        
        if (self.size3d.z == 0) {
            [self setSize3d:V3Make(self.size.x, self.size.y, 1.)];
        }
        
        self.alpha = 1.0f;
        _colorBlendFactor = 1.;
        
        _texture = texture;
        _color = color;
        
        _primitiveType = primitive;
        
        self.cullFace = NKCullFaceFront;
        
        NSString *pstring = [NKStaticDraw stringForPrimitive:primitive];
        
        if ([[NKStaticDraw meshesCache]objectForKey:pstring]) {
            _vertexBuffer = [[NKStaticDraw meshesCache]objectForKey:pstring];
        }
        
        
        else {
            
            switch (primitive) {
                    
                case NKPrimitiveSphere:
                    _vertexBuffer = [NKVertexBuffer sphereWithStacks:12 slices:14 squash:1.];
                    break;
                    
                case NKPrimitiveLODSphere:
                    _vertexBuffer = [NKVertexBuffer lodSphere:14];
                    break;
                    
                case NKPrimitiveCube:
                    _vertexBuffer = [NKVertexBuffer defaultCube];
                    break;
                    
                case NKPrimitiveRect:
                    _vertexBuffer = [NKVertexBuffer defaultRect];
                    break;
                    
                case NKPrimitiveAxes:
                    _vertexBuffer = [NKVertexBuffer axes];
                    break;
                    
                default:
                    break;
                    
            }
            
            
            [[NKStaticDraw meshesCache] setObject:_vertexBuffer forKey:pstring];
            
            NSLog(@"add primitive: %@ to mesh cache with %d vertices", pstring, _vertexBuffer.numberOfElements);
            
        }
        
        switch (primitive) {
                
            case NKPrimitiveSphere: case NKPrimitiveLODSphere:
                _drawMode = GL_TRIANGLE_STRIP;
                break;
                
            case NKPrimitiveCube:
                _drawMode = GL_TRIANGLES;
                self.cullFace = NKCullFaceBack;
                break;
                
            case NKPrimitiveRect:
                _drawMode = GL_TRIANGLES;
                self.cullFace = NKCullFaceBack;
                break;
                
            case NKPrimitiveAxes:
                _drawMode = GL_LINES;
                break;
                
            default:
                break;
                
        }
        
        
    }
    
    return self;
}

-(instancetype)initWithVertexBuffer:(NKVertexBuffer*)buffer drawMode:(GLenum)drawMode texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size {
    
    self = [super initWithSize:size];
    if (self) {
        self.size3d = size;
        
        if (self.size3d.z == 0) {
            [self setSize3d:V3Make(self.size.x, self.size.y, 1.)];
        }
        
        self.alpha = 1.0f;
        _colorBlendFactor = 1.;
        
        _texture = texture;
        _color = color;
        _vertexBuffer = buffer;
        _drawMode = drawMode;
        
        self.cullFace = NKCullFaceFront;
        
    }
    return self;
}

-(void)chooseShader {
    if (_color && _texture && ![_color isEqual:NKWHITE]) {
        self.shader = [NKShaderProgram newShaderNamed:@"colorTextureShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:1 lightNodes:self.scene.lights withBatchSize:0];
    }
    else if (_texture) {
        self.shader = [NKShaderProgram newShaderNamed:@"textureShader" colorMode:NKS_COLOR_MODE_NONE numTextures:1 lightNodes:self.scene.lights withBatchSize:0];
    }
    else if (_color) {
        self.shader = [NKShaderProgram newShaderNamed:@"colorShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:0 lightNodes:self.scene.lights withBatchSize:0];
    }
}

-(void)setParent:(NKNode *)parent {
    [super setParent:parent];
    if (!self.shader) {
        //NSLog(@"choose shader");
        [self chooseShader];
    }
    
}

-(void)setColor:(NKByteColor *)color {
    _color = color;
    [self chooseShader];
}

-(void)setTexture:(NKTexture *)texture {
    _texture = texture;
    [self chooseShader];
}

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size {
    return [self initWithObjNamed:name withSize:size normalize:false anchor:false];
}

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize {
    return [self initWithObjNamed:name withSize:size normalize:normalize anchor:false];
}

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize anchor:(bool)anchor {
    
    NSString *textureName;
    NSUInteger numElements;
    
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"space_frigate_6" ofType:@"obj"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
    int p = 0;
    if (filePath) {
        NSError *error;
        NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (myText) {
            
            NSMutableArray *vertices = [[NSMutableArray alloc] init];
            NSMutableArray *expandedVertices = [[NSMutableArray alloc] init];
            NSMutableArray *texCoords = [[NSMutableArray alloc] init];
            NSMutableArray *expandedTexCoords = [[NSMutableArray alloc] init];
            NSMutableArray *normals = [[NSMutableArray alloc] init];
            NSMutableArray *expandedNormals = [[NSMutableArray alloc] init];
            
            NSArray *lines = [myText componentsSeparatedByString:@"\n"];
			//NSLog(@"lines has %d lines", [lines count]);
			for (NSString *astring in lines){
				if ([astring hasPrefix:@"v "]){
					[vertices addObject:astring];
				}
                else if ([astring hasPrefix:@"vt "]){ // TEXCOORDS
                    [texCoords addObject:astring];
                }
                else if ([astring hasPrefix:@"vn "]){ // NORMAL
                    [normals addObject:astring];
                }
                
                else if ([astring hasPrefix:@"f "]){
                    NSArray *iArray = [astring arrayWithNoSpaces];
                    int i;
                    //NSLog(@"xxx");
                    for (i = 1; i < [iArray count]; i++) {
                        NSArray *bArray = [[iArray objectAtIndex:i] componentsSeparatedByString:@"/"];
                        
                        [expandedVertices addObject:[vertices objectAtIndex:[[bArray objectAtIndex:0] intValue] - 1]];
                        [expandedTexCoords addObject:[texCoords objectAtIndex:[[bArray objectAtIndex:1] intValue] - 1]];
                        [expandedNormals addObject:[normals objectAtIndex:[[bArray objectAtIndex:2] intValue] - 1]];
                        //extract coords for tangent
                    }
                    //NSLog(@"end xxx");
                }
                else if ([astring hasPrefix:@"t "]){ // TEXTURE NAME
                    NSArray *iArray = [astring arrayWithNoSpaces];
                    textureName = [iArray objectAtIndex:1];
                    NSLog(@"texture name is %@", textureName);
                    
                }
                else if ([astring hasPrefix:@"ex "]){
                    NSArray *iArray = [astring arrayWithNoSpaces];
                    textureName = [iArray objectAtIndex:1];
                    NSLog(@"texture name is %@", textureName);
                    
                }
                
                //}
                
            }
            
            numElements = [expandedVertices count];
            
            NKVertexArray *buffer = malloc(sizeof(NKVertexArray)*numElements);
            
            float minx = 0, maxx = 0;
            float miny = 0, maxy = 0;
            float minz = 0, maxz = 0;
            
            V3t modelNormalized;
            
            if (normalize) {
                
                for (p = 0; p < [expandedVertices count]; p++){ // FIND LARGEST VALUE
                    
                    NSArray *c = [[expandedVertices objectAtIndex:p] arrayWithNoSpaces];
                    NSUInteger cq = [c count];
                    
                    //NSLog(@"v %@ %@ %@",[c objectAtIndex:cq - 3], [c objectAtIndex:cq -2],[c objectAtIndex:cq -1]);
                    
                    float t = [[c objectAtIndex:cq - 3] floatValue];
                    if (t < minx)
                        minx = t;
                    if (t > maxx)
                        maxx = t;
                    
                    
                    t = [[c objectAtIndex:cq -2] floatValue];
                    if (t < miny)
                        miny = t;
                    if (t > maxy)
                        maxy = t;
                    
                    
                    t = [[c objectAtIndex:cq -1] floatValue];
                    if (t < minz)
                        minz = t;
                    if (t > maxz)
                        maxz = t;
                    
                };
                
                float width = fabsf(minx)+fabsf(maxx);
                float height = fabsf(miny)+fabsf(maxy);
                float depth = fabsf(minz)+fabsf(maxz);
                
                V3t offset = V3Normalize(V3Make((minx+maxx)*.5, (minx+maxx)*.5, (minx+maxx)*.5));
                
                V3t modelSize = V3Make(width, height, depth);
                
                modelNormalized = V3Normalize(modelSize);
                
                V3t modelInverse = V3Divide(V3MakeF(1.), modelSize);
                
                //modelInverseNormalized = V3Divide(V3MakeF(1.), modelNormalized);
                
//                NKLogV3(@"obj size:", modelSize);
//                NKLogV3(@"obj divisor:", modelInverse);
//                NKLogV3(@"normalized size", V3Multiply(modelSize, modelInverse));
//                NKLogV3(@"size mult", modelNormalized);
                
                for (p = 0; p < [expandedVertices count]; p++){
                    // VERTICES
                    NSArray *c = [[expandedVertices objectAtIndex:p] arrayWithNoSpaces];
                    NSUInteger cq = [c count];
                    V3t vertex = V3Make([[c objectAtIndex:cq - 3] floatValue], [[c objectAtIndex:cq - 2] floatValue], [[c objectAtIndex:cq - 1] floatValue]);
                    
                    if (anchor) {
                        buffer[p].vertex = V3Subtract(V3Multiply(vertex, modelInverse),offset);
                    }
                    else {
                        buffer[p].vertex = V3Multiply(vertex, modelInverse);
                    }
                }
                
            }
            
            else {
                
                modelNormalized = V3MakeF(1.);
                
                for (p = 0; p < [expandedVertices count]; p++){
                    // VERTICES
                    NSArray *c = [[expandedVertices objectAtIndex:p] arrayWithNoSpaces];
                    NSUInteger cq = [c count];
                    buffer[p].vertex.x = [[c objectAtIndex:cq - 3] floatValue];
                    buffer[p].vertex.y = [[c objectAtIndex:cq - 2] floatValue];
                    buffer[p].vertex.z = [[c objectAtIndex:cq - 1] floatValue];
                }
            }
            for (p = 0; p < [expandedVertices count]; p++){
                // TEXCOORDS
                NSArray *c =  [[expandedTexCoords objectAtIndex:p] componentsSeparatedByString:@" "];
                NSUInteger cq = [c count];
                buffer[p].texCoord.x = [[c objectAtIndex:cq-2] floatValue];
                buffer[p].texCoord.y = [[c objectAtIndex:cq-1] floatValue];
                // NORMALS
                c =  [[expandedNormals objectAtIndex:p] componentsSeparatedByString:@" "];
                cq = [c count];
                buffer[p].normal.x = [[c objectAtIndex:cq -3] floatValue];
                buffer[p].normal.y = [[c objectAtIndex:cq -2] floatValue];
                buffer[p].normal.z = [[c objectAtIndex:cq - 1] floatValue];
                // COLORS
                buffer[p].color.r = 1.0;
                buffer[p].color.g = 1.0;
                buffer[p].color.b = 1.0;
                buffer[p].color.a = 1.0;
            }
            
            NKVertexBuffer *buf;
            
            if ([[NKStaticDraw meshesCache]objectForKey:name]) {
                buf = [[NKStaticDraw meshesCache]objectForKey:name];
                textureName = name;
            }
            
            else {
                buf = [[NKVertexBuffer alloc] initWithSize:sizeof(NKVertexArray)*numElements data:buffer setup:^{
                    glEnableVertexAttribArray(NKSVertexAttribPosition);
                    glVertexAttribPointer(NKSVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                                          sizeof(NKVertexArray), BUFFER_OFFSET(0));
                    
                    glEnableVertexAttribArray(NKSVertexAttribNormal);
                    glVertexAttribPointer(NKSVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,
                                          sizeof(NKVertexArray), BUFFER_OFFSET(sizeof(V3t)));
                    
                    glEnableVertexAttribArray(NKSVertexAttribTexCoord0);
                    glVertexAttribPointer(NKSVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                                          sizeof(NKVertexArray), BUFFER_OFFSET(sizeof(V3t)*2));
                    
                    glEnableVertexAttribArray(NKSVertexAttribColor);
                    glVertexAttribPointer(NKSVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
                                          sizeof(NKVertexArray), BUFFER_OFFSET(sizeof(V3t)*2+sizeof(V2t)));
                }];
                
                [[NKStaticDraw meshesCache] setObject:buf forKey:name];
                
                NSLog(@"cache obj named: %@", name);
            }
            
            free(buffer);
            
            NKLogV3(@"object bounding box", V3Multiply(size, modelNormalized));
            
            if (!textureName) {
                self = [self initWithVertexBuffer:buf drawMode:GL_TRIANGLES texture:nil color:NKWHITE size:V3Multiply(size, modelNormalized)];
            }
            else{
                self = [self initWithVertexBuffer:buf drawMode:GL_TRIANGLES texture:[NKTexture textureWithImageNamed:textureName] color:NKWHITE size:V3Multiply(size, modelNormalized)];
            }
            
            self.cullFace = NKCullFaceBack;
            
            return self;
            
        }
        
    }
    
    return nil;
    
}

//
//-(void)setTransparency:(F1t)transparency {
//    [super setTransparency:transparency];
//    _intColor.a = self.alpha;
//}
//
//-(void)recursiveAlpha:(F1t)alpha {
//    [super recursiveAlpha:alpha];
//    _intColor.a = self.alpha;
//}

//-(C4t)glColor {
//    C4t col;
//    if (_texture) {
//        CGFloat c[4];
//
//        [_color getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
//
//        if (self.colorBlendFactor > 0.) {
//            F1t colBlend = self.colorBlendFactor;
//            col.r =cblend(c[0],colBlend);
//            col.g =cblend(c[1],colBlend);
//            col.b =cblend(c[2],colBlend);
//        }
//        else {
//            col.r = c[0];
//            col.g = c[1];
//            col.b = c[2];
//        }
//
//        col.a = c[3] * self.alpha;
//        //  [[self textureColorForSprite] getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
//    }
//    else {
//        CGFloat c[4];
//
//        [_color getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
//        col.r = c[0];
//        col.g = c[1];
//        col.b = c[2];
//        col.a = c[3] * self.alpha;
//    }
//    return col;
//}

-(C4t)glColor {
    return [[self color] colorWithBlendFactor:_colorBlendFactor alpha:self.alpha];
}

-(int)lodForDistance {
    
    float distance = V3Distance(self.scene.camera.getGlobalPosition, self.getGlobalPosition) * .125;
    
    float size = self.size.width;
    
    int lod = 0;
    
    if (size < distance) {
        
        float diff = (distance - size) / distance;
        
        lod = diff * ((float)_vertexBuffer.numberOfElements);
    }
    
    return lod;
}


-(void)customDraw {
    
    if (self.color || _texture) {
        
        if (self.shader) {
            self.scene.activeShader = self.shader;
        }
        
        M16t modelView = M16Multiply(self.scene.camera.viewMatrix,M16ScaleWithV3(self.scene.stack.currentMatrix, _size3d));
        
        if([self.scene.activeShader uniformNamed:NKS_M16_MV] ){
            [[self.scene.activeShader uniformNamed:NKS_M16_MV] bindM16:modelView];
        }
        
        if ([self.scene.activeShader uniformNamed:NKS_M9_NORMAL]){
            [[self.scene.activeShader uniformNamed:NKS_M9_NORMAL] bindM9:M16GetInverseNormalMatrix(modelView)];
        }
        
        M16t mvp = M16Multiply(self.scene.camera.projectionMatrix,modelView);
        
        [[self.scene.activeShader uniformNamed:NKS_M16_MVP] bindM16:mvp];
        
        if ([self.scene.activeShader uniformNamed:NKS_V4_COLOR]){
            [[self.scene.activeShader uniformNamed:NKS_V4_COLOR] bindV4:[self glColor]];
        }
        
        if (_texture) {
            if (self.scene.boundTexture != _texture) {
                [_texture bind];
                self.scene.boundTexture = _texture;
            }
        }
        
        if (self.scene.boundVertexBuffer != _vertexBuffer) {
            [_vertexBuffer bind];
            self.scene.boundVertexBuffer = _vertexBuffer;
        }
        
        if (_primitiveType == NKPrimitiveLODSphere) {
            int lod = [self lodForDistance];
            glDrawArrays(_drawMode, _vertexBuffer.elementOffset[lod], _vertexBuffer.elementSize[lod] );
            
        }
        else {
            glDrawArrays(_drawMode, 0, _vertexBuffer.numberOfElements);
        }
        
    }
    
}

-(void)customdrawWithHitShader {
    
    [[self.scene.activeShader uniformNamed:NKS_M16_MVP] bindM16:M16Multiply(self.scene.camera.viewProjectionMatrix, M16ScaleWithV3(self.scene.stack.currentMatrix, self.size3d))];
    
    [[self.scene.activeShader uniformNamed:NKS_V4_COLOR] bindV4:self.uidColor.C4Color];
    
    if (self.scene.boundVertexBuffer != _vertexBuffer) {
        [_vertexBuffer bind];
        self.scene.boundVertexBuffer = _vertexBuffer;
    }
    
    if (_primitiveType == NKPrimitiveLODSphere) {
        int lod = [self lodForDistance];
        glDrawArrays(_drawMode, _vertexBuffer.elementOffset[lod], _vertexBuffer.elementSize[lod] );
    }
    else {
        glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexBuffer.numberOfElements);
        
    }
}

@end

