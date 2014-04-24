//
//  NKTextureManager.m
//  nike3dField
//
//  Created by Chroma Developer on 3/27/14.
//
//

#import "NKTextureManager.h"
#import "NKTexture.h"

@implementation NKTextureManager

static NKTextureManager *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        imageCache = [NSMutableDictionary dictionary];
        labelCache = [NSMutableDictionary dictionary];
        _textureThread = dispatch_queue_create("TEX_BG_THREAD", DISPATCH_QUEUE_SERIAL);
        _defaultTexture = -1;
        NSLog(@"texture manager loaded");
    }
    
    return self;
}

+ (NKTextureManager *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}

+(NSMutableDictionary*)imageCache {
    return [[NKTextureManager sharedInstance] imageCache];
}


-(NSMutableDictionary*)imageCache {
    return imageCache;
}

+(NSMutableDictionary*)labelCache {
    return [[NKTextureManager sharedInstance] labelCache];
}


-(NSMutableDictionary*)labelCache {
    return labelCache;
}

+(dispatch_queue_t)textureThread {
    return [[NKTextureManager sharedInstance] textureThread];
    
}

-(dispatch_queue_t)textureThread {
    return _textureThread;
}

+(GLuint)defaultTextureLocation {
    return [[NKTextureManager sharedInstance] defaultTextureLocation];
}

-(GLuint)defaultTextureLocation{
    if (_defaultTexture == -1) {
        NKTexture *defaultTex = [NKTexture blankTexture];
        _defaultTexture = [defaultTex glTexLocation];
        NSLog(@"blank tex loc: %d",_defaultTexture);
    }
    return _defaultTexture;
}


@end
