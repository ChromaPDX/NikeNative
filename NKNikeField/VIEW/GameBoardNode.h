//
//  GameBoardNode.h
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NKScrollNode.h"


@interface GameBoardNode : NKSpriteNode

@property (nonatomic, strong) NSArray* goalSprites;
@property (nonatomic) NSInteger gameBoardViewScrollOffset;

@end
