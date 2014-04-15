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
    CardCategorySpecial
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
