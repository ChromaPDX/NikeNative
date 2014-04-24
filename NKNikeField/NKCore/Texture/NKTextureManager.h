//
//  NKTextureManager.h
//  nike3dField
//
//  Created by Chroma Developer on 3/27/14.
//
//

#import <Foundation/Foundation.h>

@class NKTexture;

@interface NKTextureManager : NSObject
{
    NSMutableDictionary *imageCache;
    NSMutableDictionary *labelCache;
    dispatch_queue_t _textureThread;

}
+ (NKTextureManager *)sharedInstance;
+ (NSMutableDictionary*) imageCache;
+ (NSMutableDictionary*) labelCache;
+ (dispatch_queue_t) textureThread;
+ (GLuint) defaultTextureLocation;

@property (nonatomic)     GLuint defaultTexture;

@end
