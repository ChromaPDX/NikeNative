//
//  NKTextureManager.h
//  nike3dField
//
//  Created by Chroma Developer on 3/27/14.
//
//

#import <Foundation/Foundation.h>

@interface NKTextureManager : NSObject
{
    NSMutableDictionary *imageCache;
    NSMutableDictionary *labelCache;
}
+ (NKTextureManager *)sharedInstance;
+ (NSMutableDictionary*) imageCache;
+ (NSMutableDictionary*) labelCache;

@end
