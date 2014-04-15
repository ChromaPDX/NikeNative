//
//  GameBoardNode.h
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NKScrollNode.h"

typedef enum Z_INDEX_CHART {
    
    Z_INDEX_BASE = 0,
    Z_INDEX_WINDOW = 10,
    Z_INDEX_BOARD = 20,
    Z_INDEX_HUD = 30,
    Z_INDEX_FX = 40,
    
    
    Z_BOARD_LOW = 1,
    Z_BOARD_ZONE = 2,
    Z_BOARD_PLAYER = 3,
    Z_BOARD_BALL = 4,
    Z_BOARD_EVENT = 5
    
} Z_INDEX_CHART;

@interface GameBoardNode : NKSpriteNode

//@property (nonatomic, strong) UXWindow *uxWindow;
//@property (nonatomic, strong) ScoreBoard *scoreBoard;
//@property (nonatomic, strong) BallSprite* ballSprite;
@property (nonatomic, strong) NSArray* goalSprites;
@property (nonatomic) NSInteger gameBoardViewScrollOffset;

@end
