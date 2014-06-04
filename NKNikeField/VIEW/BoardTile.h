//
//  BoardTile.h
//  nike3dField
//
//  Created by Chroma Developer on 3/3/14.
//
//

#import "NKSpriteNode.h"
#import "BoardLocation.h"

@class BoardLocation;
@class GameScene;

@interface BoardTile : NKSpriteNode

-(instancetype)initWithTexture:(NKTexture *)texture color:(NKByteColor *)color size:(S2t)size;

// MODEL
@property (nonatomic, strong) BoardLocation *location;


// VIEW
@property (nonatomic, weak) GameScene *delegate;

@property (nonatomic, strong) NKMeshNode *block;

@property (nonatomic, strong) NKSpriteNode *overlay;

-(void)setTextureForBorder:(BorderMask)border;
-(void)setOverlayTextureForBorder:(BorderMask)border;
-(void)showOverlay;
-(void)hideOverlay;


@end
