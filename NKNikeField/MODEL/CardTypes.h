//
//  CardCategorys.h
//  ChromaNSFW
//
//  Created by Chroma Developer on 11/26/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#ifndef ChromaNSFW_CardTypes_h
#define ChromaNSFW_CardTypes_h

typedef NS_ENUM(int32_t, CardCategory) {
    CardCategoryNull,
    
    CardCategoryPlayer,
    CardCategoryBall,
    
    CardCategoryKick,
    CardCategoryChallenge,
    CardCategoryMove,
    CardCategorySpecial,
    CardCategoryGeneral
};

typedef NS_ENUM(int32_t, CardMoveCategory) {
    CardMoveCategoryNull = 0,
    CardMoveCategoryBishop = 1,
    CardMoveCategoryQueen = 2,
    CardMoveCategoryRook = 3,
    CardMoveCategoryKnight = 4
};

typedef NS_ENUM(int32_t, CardKickCategory) {
    CardKickCategoryNull = 0,
    CardKickCategoryStraight = 1,
    CardKickCategoryLob = 2,
    CardKickCategoryBeckem = 3,
    CardKickCategoryDrop = 4,
    CardKickCategoryQueen = 5
};

typedef NS_ENUM(int32_t, CardChallengeCategory) {
    CardChallengeCategoryNull = 0,
  //  CardChallengeCategoryRook = 1,
    CardChallengeCategoryBishop = 1,
    CardChallengeCategoryVertical = 2,
    CardChallengeCategoryHorizantal = 3
};

// SPECIALS

typedef NS_ENUM(int32_t, CardSpecialCategory) {
    CardSpecialCategoryNull = 0,
    CardSpecialCategoryFreeze = 1,
    CardSpecialCategoryNoLegs = 2,
    CardSpecialCategorySuccubus = 3,
    CardSpecialCategoryBlock = 4,
    CardSpecialCategoryDeRez = 5,
    CardSpecialCategoryNewDeal = 6,
    CardSpecialCategoryPredictiveAnalysis = 7
};

#define Card_Freeze @"freeze"
#define Card_NoLegs @"noLegs"
#define Card_Succubus @"succubus"
#define Card_Block @"block"
#define Card_DeRez @"deRez"
#define Card_NewDeal @"newDeal"
#define Card_PredictiveAnalysis @"predictiveAnalysis"

typedef NS_ENUM(int32_t, EventType) {
    kNullAction,
    // Player Actions
    kEventAddPlayer,
    kEventRemovePlayer,
    
    // Field Actions
    kEventSetBallLocation,
    kEventResetPlayers,
    kEventGoalKick,
    
    // Cards / Card Actions
    kEventSequence,
    kEventDraw,
    kEventPlayCard,
    kEventKickPass,
    kEventKickGoal,
    kEventKickGoalLoss,
    kEventChallenge,
    kEventMove,
    kEventAddSpecial,
    kEventRemoveSpecial,
    kEventFreeze,
    kEventNoLegs,
    kEventSuccubus,
    kEventBlock,
    kEventDeRez,
    kEventNewDeal,
    kEventPredictiveAnalysis,
    kEventKickMode,
    kEventKick,

    // Deck
    kEventShuffleDeck,
    kEventReShuffleDeck,
    
    // Turn State
    kEventStartGame,
    kEventKickoff,
    kEventStartTurn,
    kEventStartTurnDraw,
    kEventEndTurn,
    
    // Camera
    kEventMoveCamera,
    kEventMoveBoard,
 
};

#endif
