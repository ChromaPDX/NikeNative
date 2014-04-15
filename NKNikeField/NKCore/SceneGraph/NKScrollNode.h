/***********************************************************************
 
 Written by Leif Shackelford
 Copyright (c) 2014 Chroma.io
 All rights reserved. *
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met: *
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of CHROMA GAMES nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission. *
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE. *
 ***********************************************************************/

#import "NKSpriteNode.h"

#define DEFAULT_FONT_STRING "ofxTableViewDefault.ttf"
#define DEFAULT_FONT_SIZE 16

typedef enum ScrollPhase {
    ScrollPhaseNil,
    ScrollPhaseBegan,
    ScrollPhaseRecognized,
    ScrollPhaseBeginFail,
    ScrollPhaseFailed,
    ScrollPhaseEnded,
    ScrollPhaseRestitution
} ScrollPhase;

typedef enum TransitionStyle {
    TransitionStyleNone,
    TransitionStyleEnterFromRight,
    TransitionStyleEnterFromLeft,
    TransitionStyleExitToLeft,
    TransitionStyleExitToRight,
    TransitionStyleZoomIn,
    TransitionStyleZoomOut,
    TransitionStyleFade
} TransitionStyle;

@class NKScrollNode;

@protocol NKTableCellDelegate
    
    -(void)cellWasSelected:(NKScrollNode*)cell;
    -(void)cellWasDeSelected:(NKScrollNode*)cell;
    

@end

@interface NKScrollNode : NKSpriteNode

{ // private
    
    int             state;
    
    // Touch Handliing
    
    
    bool cdirty;
    
    int contentSize;
    // SCROLLING INTERNAL VARIABLES
    
    int restitution;
    int easeIn;
    bool easeOut;
    
    int xOrigin;
    int yOrigin;
    float scrollVel;
    float counterVel;
    float drag ;
    
    float _scale;
    
    float alpha;
    
    
    
    bool            clipToBounds;
    bool            isModal;
    
    
    
    int             scrollPostion;
    
    
}

// INIT

-(instancetype) initWithParent:(NKScrollNode *)parent autoSizePct:(float)autoSizePct;

@property (nonatomic, weak) id <NKTableCellDelegate> delegate;

// Scroll

@property    (nonatomic) bool            highlighted;
@property    (nonatomic) ScrollPhase scrollPhase;
@property   (nonatomic) float scrollPosition;
@property   (nonatomic) float autoSizePct;
@property   (nonatomic)  int displayId;
@property   (nonatomic) bool            scrollDirectionVertical;
@property   (nonatomic) bool            scrollingEnabled;
@property   (nonatomic) bool            shouldRasterize;
@property   (nonatomic)   bool fdirty;
@property   (nonatomic) int             verticalPadding;
@property   (nonatomic) int             horizontalPadding;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColor;

-(void) setScrollPosition:(int) offset animated:(bool) animated;

// Getter based properties
@property (nonatomic, readonly) float outOfBounds;
@property (nonatomic, readonly) float contentSize;
@property (nonatomic, readonly) bool shouldCull;

@end
