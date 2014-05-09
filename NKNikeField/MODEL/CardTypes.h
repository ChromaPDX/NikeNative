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

typedef NS_ENUM(int32_t, CardSpecialCategory) {
    CardSpecialCategoryNull = 0,
    CardSpecialCategoryFreeze = 1
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
};

typedef NS_ENUM(int32_t, CardChallengeCategory) {
    CardChallengeCategoryNull = 0,
    CardChallengeCategoryRook = 1,
    CardChallengeCategoryBishop = 2,
    CardChallengeCategoryVertical = 3,
    CardChallengeCategoryHorizantal = 4
};

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
    kEventChallenge,
    kEventMove,
    kEventAddSpecial,
    kEventRemoveSpecial,
    kEventFreeze,
    
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
