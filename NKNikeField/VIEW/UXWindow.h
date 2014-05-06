
#import "NKNode.h"

@class GameScene;
@class Card;
@class CardSprite;
@class ButtonSprite;
@class AlertSprite;
@class UXWindow;

@interface BigCards : NKPickerNode
    @property NSMutableArray *cards;
-(void)addCard:(NKNode*)card;
@end

@interface PlayerHand : NKNode <NKTableCellDelegate>{
    S2t cardSize;
}
    @property (nonatomic, weak) UXWindow* delegate;
    @property (nonatomic, weak) Player* player;
    @property (nonatomic, strong) NSMutableDictionary *cardSprites;
    @property (nonatomic, strong) NSMutableArray *myCards;
    @property (nonatomic, strong) NKLabelNode *playerName;

    @property (nonatomic, strong) BigCards *bigCards;

    -(instancetype)initWithPlayer:(Player*)p delegate:(UXWindow*)delegate;
    -(void)addCard:(Card*)card;
    -(void)removeCard:(Card*)card;
    -(void)sortCards;
    -(void)sortCardsAnimated:(BOOL)animated WithCompletionBlock:(void (^)())block;
    -(void)shuffleAroundCard:(CardSprite*)card;
@end

@interface UXWindow : NKSpriteNode


@property (nonatomic, strong) NSMutableDictionary *playerHands;

@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Player* selectedPlayer;
@property (nonatomic, weak) Card* selectedCard;

-(CardSprite*)spriteForCard:(Card*)c;

@property (nonatomic) BOOL enableSubmitButton;
@property (nonatomic, strong) AlertSprite *alert;

-(void)refreshCardsForPlayer:(Player *)p WithCompletionBlock:(void (^)())block;

-(void)cardTouchMoved:(CardSprite*)card atPoint:(P2t)point;
-(void)cardTouchBegan:(CardSprite*)card atPoint:(P2t)point;
-(void)cardTouchEnded:(CardSprite*)card atPoint:(P2t)point;

-(void)cardDoubleTap:(CardSprite*)card;

-(BoardLocation*)canPlayCard:(Card*)card atPosition:(P2t)pos;

-(void)setActionButtonTo:(NSString*)function;
-(void)cleanup;

@end
