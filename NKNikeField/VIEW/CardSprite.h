//
//  CardSprite.h
//  cardGame
//
//  Created by Chroma Dev Pod on 9/17/13.
//  Copyright (c) 2013 ChromaGames. All rights reserved.
//

#import "NKSpriteNode.h"

#import "ButtonSprite.h"

@class Card;
@class GameScene;
@class UXWindow;

@interface CardSprite : NKSpriteNode{

    NKLabelNode *cardName;
    NKLabelNode *cost;
    NKLabelNode *actionPoints;
    NKLabelNode *kick;
    NKLabelNode *dribble;
    NKLabelNode *slash;
    NKLabelNode *save; // goalie only
    NKLabelNode *_doubleName;
    
}

@property (nonatomic) CGPoint touchOffset;
@property (nonatomic) CGPoint realPosition;
@property (nonatomic) BOOL flipped;

@property (nonatomic) BOOL hasShadow;
@property (nonatomic) BOOL hovering;
// Views

@property (nonatomic, weak) Card* model;
@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) UXWindow *window;
@property (nonatomic) CGPoint origin;
@property (nonatomic) int order;

@property (nonatomic, strong) NKSpriteNode *art;
@property (nonatomic,strong) NKSpriteNode *shadow;

-(NKColor*)colorForCategory;

@end
