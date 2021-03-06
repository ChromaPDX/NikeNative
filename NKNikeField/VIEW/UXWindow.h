
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

@interface ManagerHand : NKNode <NKTableCellDelegate>{
    S2t cardSize;
}
@property (nonatomic, weak) UXWindow* delegate;
@property (nonatomic, weak) Manager* manager;
@property (nonatomic, strong) NSMutableDictionary *cardSprites;
@property (nonatomic, strong) NSMutableArray *myCards;
@property (nonatomic, strong) NKLabelNode *playerName;

@property (nonatomic, strong) BigCards *bigCards;

-(instancetype)initWithManager:(Manager*)m delegate:(UXWindow*)delegate;
-(void)addCard:(Card*)card;
-(void)removeCard:(Card*)card;
-(void)playCard:(Card *)card;
-(void)sortCardsAnimated:(BOOL)animated WithCompletionBlock:(void (^)())block;

-(void)shuffleAroundCard:(Card*)card;
-(void)shuffleAroundCardSprite:(CardSprite *)card;

@end

@interface UXWindow : NKSpriteNode


//@property (nonatomic, strong) NSMutableDictionary *playerHands;

@property (nonatomic, strong) ManagerHand *managerHand;

@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Player* selectedPlayer;
@property (nonatomic, weak) Card* selectedCard;

-(CardSprite*)spriteForCard:(Card*)c;

@property (nonatomic) BOOL enableSubmitButton;
@property (nonatomic, strong) AlertSprite *alert;

-(void)refreshCardsForManager:(Manager *)m WithCompletionBlock:(void (^)())block;
-(void)removeCardsAnimated:(BOOL)animated WithCompletionBlock:(void (^)())block;

-(void)cardTouchMoved:(CardSprite*)card atPoint:(P2t)point;
-(void)cardTouchBegan:(CardSprite*)card atPoint:(P2t)point;
-(void)cardTouchEnded:(CardSprite*)card atPoint:(P2t)point;

-(void)cardDoubleTap:(CardSprite*)card;
-(void)playCard:(Card *)card;

-(BoardLocation*)canPlayCard:(Card*)card atPosition:(P2t)pos;

-(void)setActionButtonTo:(NSString*)function;
-(void)cleanup;

@end
