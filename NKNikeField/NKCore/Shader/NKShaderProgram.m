//
//  NOCShaderProgram.m
//  Nature of Code
//
//  Created by William Lindmeier on 2/2/13.
//  Copyright (c) 2013 wdlindmeier. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKShaderProgram
{
    NSDictionary *_uniformLocations;
    NSString *_vertShaderPath;
    NSString *_fragShaderPath;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        self.name = name;
        
        _vertShaderPath = [[NSBundle mainBundle] pathForResource:self.name
                                                          ofType:@"vsh"];
        
        _fragShaderPath = [[NSBundle mainBundle] pathForResource:self.name
                                                          ofType:@"fsh"];
        
        // NOTE: Maybe this should just return nil?
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_vertShaderPath] );
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_fragShaderPath] );
        
        _vertexSource =  [NSString stringWithContentsOfFile:_vertShaderPath encoding:NSUTF8StringEncoding error:nil];
        _fragmentSource = [NSString stringWithContentsOfFile:_fragShaderPath encoding:NSUTF8StringEncoding error:nil];

    }
    return self;
}

- (instancetype)initWithVertexShader:(NSString *)vertShaderName fragmentShader:(NSString *)fragShaderName
{
    self = [super init];
    if(self)
    {
        int dotIndex = [vertShaderName rangeOfString:@"."].location;
        if ( dotIndex != NSNotFound )
        {
            self.name = [vertShaderName substringToIndex:dotIndex];
        }
        else
        {
            self.name = vertShaderName;
        }
        
        _vertShaderPath = [[NSBundle mainBundle] pathForResource:vertShaderName ofType:nil];
        _fragShaderPath = [[NSBundle mainBundle] pathForResource:fragShaderName ofType:nil];
        
        // NOTE: Maybe this should just return nil?
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_vertShaderPath] );
        assert( [[NSFileManager defaultManager] fileExistsAtPath:_fragShaderPath] );
        
        _vertexSource =  [NSString stringWithContentsOfFile:_vertShaderPath encoding:NSUTF8StringEncoding error:nil];
        _fragmentSource = [NSString stringWithContentsOfFile:_fragShaderPath encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

-(instancetype)initWithVertexSource:(NSString *)vertexSource fragmentSource:(NSString *)fragmentSource {
    self = [super init];
    if(self)
    {
        _vertexSource = vertexSource;
        _fragmentSource = fragmentSource;
    }
    return self;
}

+ (instancetype)defaultShader {
    NKShaderProgram* newShader = [[NKShaderProgram alloc] initWithVertexSource:nkDefaultTextureVertexShader fragmentSource:nkDefaultTextureFragmentShader];
    
    return newShader;
}
                                
- (NSDictionary*) defaultAttributes {
    return @{ @"a_position"   : @(NKVertexAttribPosition),
              @"a_normal"     : @(NKVertexAttribNormal),
              @"a_color"      : @(NKVertexAttribColor),
              @"a_texCoord0"  : @(NKVertexAttribTexCoord0),
              @"a_texCoord1"  : @(NKVertexAttribTexCoord1),
              };
}

- (NSArray*)defaultUniformNames {
    return @[UNIFORM_MODELVIEWPROJECTION_MATRIX, UNIFORM_NORMAL_MATRIX, USE_UNIFORM_COLOR, UNIFORM_COLOR, UNIFORM_NUM_TEXTURES];
}

- (BOOL)load
{
    
    if (!_attributes) {
        _attributes = [[self defaultAttributes] mutableCopy];
    }
    
    if (!_uniformNames) {
        _uniformNames = [self defaultUniformNames];
    }
    
    GLuint vertShader, fragShader;
    
    // Create shader program.
    self.glPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    if ( ![self compileShader:&vertShader type:GL_VERTEX_SHADER shaderSource:_vertexSource] )
    {
        NSLog(@"Failed to compile VERTEX shader: %@", self.name);
        return NO;
    }
    
    // Create and compile fragment shader.
    if ( ![self compileShader:&fragShader type:GL_FRAGMENT_SHADER shaderSource:_fragmentSource] )
    {
        NSLog(@"Failed to compile FRAGMENT shader: %@", self.name);
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(self.glPointer, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.glPointer, fragShader);
    
    for( NSString *attrName in self.attributes.allKeys )
    {
        // PUSH METHOD
        NSNumber *attrType = self.attributes[attrName];
        glEnableVertexAttribArray([attrType intValue]);
        glBindAttribLocation(self.glPointer, [attrType intValue], [attrName UTF8String]);
    }
    
    // Link program.
    if ( ![self linkProgram:self.glPointer] )
    {
        
        NSLog(@"Failed to link program: %@", self.name);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.glPointer)
        {
            glDeleteProgram(self.glPointer);
            self.glPointer = 0;
        }
        
        return NO;
    }
    
    for( NSString *attrName in self.attributes.allKeys )
    {
        // PULL METHOD
        GLint glName = glGetAttribLocation(self.glPointer, [attrName UTF8String]);
        glEnableVertexAttribArray(glName);
        [_attributes setValue:@(glName) forKey:attrName];
        
        //NSLog(@"shader setup slot %d, string %@",glName, attrName);
    }
    
    NSMutableDictionary *uniformLocations = [NSMutableDictionary dictionaryWithCapacity:self.uniformNames.count];
    
    for(NSString *uniName in self.uniformNames)
    {
        int uniLoc = glGetUniformLocation(self.glPointer, [uniName UTF8String]);
        if (uniLoc > -1)
        {
            uniformLocations[uniName] = @(uniLoc);
        }
        else
        {
            NSLog(@"WARNING: Couldn't find location for uniform named: %@", uniName);
        }
    }
    
    // Store the locations in an immutable collection
    _uniformLocations = [NSDictionary dictionaryWithDictionary:uniformLocations];
    
    // Release vertex and fragment shaders.
    if (vertShader)
    {
        glDetachShader(self.glPointer, vertShader);
        glDeleteShader(vertShader);
    }
    
    if (fragShader)
    {
        glDetachShader(self.glPointer, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
    
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    return [self compileShader:shader type:type shaderSource:
            [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type shaderSource:(NSString *)shaderSource {

    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[shaderSource UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader: %@", self.name);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
    
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}

- (void)unload
{
    if (self.glPointer)
    {
        NSLog(@"unload shader %d", self.glPointer);
        glDeleteProgram(self.glPointer);
        self.glPointer = 0;
    }
}

-(void)dealloc {

    [self unload];
}

- (void)use
{
    glUseProgram(self.glPointer);
}

#pragma mark - Helpers

- (void)setFloat:(const GLfloat)f forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform1f([uniLoc intValue], f);
}

- (void)setInt:(const GLint)i forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    //assert(uniLoc);
    if ([uniLoc intValue]) {
        glUniform1i([uniLoc intValue], i);
    }
   
}

- (void)setMatrix3:(const M9t)mat forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniformMatrix3fv([uniLoc intValue], 1, 0, mat.m);
}

- (void)setMatrix4:(const M16t)mat forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniformMatrix4fv([uniLoc intValue], 1, 0, mat.m);
}

- (void)set1DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform1fv([uniLoc intValue], num, array);
}

- (void)set2DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform2fv([uniLoc intValue], num, array);
}

- (void)set3DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform3fv([uniLoc intValue], num, array);
}

- (void)set4DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform4fv([uniLoc intValue], num, array);
}

- (void)setVec4:(V4t)vec4 forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform4f([uniLoc intValue], vec4.x, vec4.y, vec4.z, vec4.w);
}

- (void)setVec3:(V3t)vec3 forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform3f([uniLoc intValue], vec3.x, vec3.y, vec3.z);
}

- (void)setVec2:(V2t)vec2 forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform2f([uniLoc intValue], vec2.x, vec2.y);
}

- (void)setColor:(UIColor *)color forUniform:(NSString *)uniformName
{
    GLfloat components[4];
    NOCColorComponentsForColor(components, color);
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    glUniform4f([uniLoc intValue], components[0], components[1], components[2], components[3]);
}

- (void)bindTexture:(NKTexture *)texture forUniform:(NSString *)uniformName
{
    NSNumber *uniLoc = self.uniformLocations[uniformName];
    assert(uniLoc);
    [texture enableAndBindToUniform:[uniLoc intValue]];
}

- (void)enableAttribute3D:(NSString *)attribName withArray:(const GLvoid*)arrayValues
{
    NSNumber *attrVal = self.attributes[attribName];
    assert(attrVal);
    GLuint attrLoc = [attrVal intValue];
    glVertexAttribPointer(attrLoc, 3, GL_FLOAT, GL_FALSE, 0, arrayValues);
    glEnableVertexAttribArray(attrLoc);
}

- (void)enableAttribute2D:(NSString *)attribName withArray:(const GLvoid*)arrayValues
{
    NSNumber *attrVal = self.attributes[attribName];
    assert(attrVal);
    GLuint attrLoc = [attrVal intValue];
    glVertexAttribPointer(attrLoc, 2, GL_FLOAT, GL_FALSE, 0, arrayValues);
    glEnableVertexAttribArray(attrLoc);
}

- (void)disableAttributeArray:(NSString *)attribName
{
    NSNumber *attrVal = self.attributes[attribName];
    assert(attrVal);
    GLuint attrLoc = [attrVal intValue];
    glDisableVertexAttribArray(attrLoc);
}

@end
