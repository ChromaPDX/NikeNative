//
//  AlertSprite.h
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NKSpriteNode.h"

@protocol AlertSpriteDelegate <NSObject>

-(void)alertDidCancel;

@end

@interface AlertSprite : NKSpriteNode

@property (nonatomic, weak) id <AlertSpriteDelegate> delegate;

@end
