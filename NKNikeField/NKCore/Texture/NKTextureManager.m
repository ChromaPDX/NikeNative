//
//  NKTextureManager.m
//  nike3dField
//
//  Created by Chroma Developer on 3/27/14.
//
//

#import "NKTextureManager.h"

@implementation NKTextureManager

static NKTextureManager *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        imageCache = [NSMutableDictionary dictionary];
        labelCache = [NSMutableDictionary dictionary];
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



@end
