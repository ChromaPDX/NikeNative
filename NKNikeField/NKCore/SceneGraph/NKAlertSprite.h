//
//  AlertSprite.h
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NKSpriteNode.h"

@class NKAlertSprite;

@protocol NKAlertSpriteDelegate <NSObject>

-(void)presentAlert:(NKAlertSprite*)alert animated:(BOOL)animated;
-(void)dismissAlertAnimated:(BOOL)animated;
-(void)alertDidCancel;
-(void)alertDidSelectOption:(int)option;

@end

@interface NKAlertSprite : NKSpriteNode

@property (nonatomic, weak) id <NKAlertSpriteDelegate> delegate;

@end
