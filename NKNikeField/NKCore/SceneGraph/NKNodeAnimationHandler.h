/***********************************************************************
 * Written by Leif Shackelford
 * Copyright (c) 2014 Chroma Games
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Chroma Games nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ***********************************************************************/


#import <Foundation/Foundation.h>

@class NKAction;
@class NKNode;

typedef NS_ENUM(NSInteger, NKActionTimingMode) {
    NKActionTimingLinear,
    NKActionTimingEaseIn,
    NKActionTimingEaseOut,
    NKActionTimingEaseInEaseOut
} NS_ENUM_AVAILABLE(10_9, 7_0);

static inline F1t weightedAverage (F1t src, F1t dst, F1t d);
static inline F1t logAverage (F1t src, F1t dst, F1t d);
static inline V3t getTweenPoint(V3t src, V3t dst, F1t d);

typedef void (^ActionBlock)(NKNode *node, F1t completion);

@interface NKAction : NSObject

//@property (nonatomic,weak) NKNode *node;

@property (nonatomic) NKActionTimingMode timingMode;
@property (nonatomic) CGFloat speed;
@property (nonatomic, copy) ActionBlock actionBlock;
@property (nonatomic, copy) void (^completionBlock)(void);
@property (nonatomic) F1t progress;
@property (nonatomic) F1t duration;
@property (nonatomic) NSInteger repeats;
@property (nonatomic) bool serial;

@property (nonatomic, weak) NKAction *parentAction;
@property (nonatomic, weak) NodeAnimationHandler *handler;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, weak) NKNode *target;

@property (nonatomic) V3t startPos;
@property (nonatomic) V3t endPos;
@property (nonatomic) Q4t startOrientation;
@property (nonatomic) Q4t endOrientation;

@property (nonatomic) M16t startMatrix;
@property (nonatomic) M16t endMatrix;

@property (nonatomic) F1t startFloat;
@property (nonatomic) F1t endFloat;

@property (nonatomic) bool reset;


- (NKAction *)reversedAction;

- (void) runCompletion;
- (void) stop;

- (bool)updateWithTimeSinceLast:(F1t) dt;


// 3D Additions

-(instancetype) initWithDuration:(F1t)duration;

+ (NKAction *)move3dByX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z duration:(F1t)sec;
+ (NKAction *)move3dBy:(V3t)delta duration:(F1t)sec;
+ (NKAction *)move3dTo:(V3t)location duration:(F1t)sec;

+(NKAction *)rotateXByAngle:(CGFloat)radians duration:(F1t)sec;
+(NKAction *)rotateYByAngle:(CGFloat)radians duration:(F1t)sec;
+(NKAction *)rotate3dByAngle:(V3t)angles duration:(F1t)sec;

// SK Compatibility list

+ (NKAction *)moveByX:(CGFloat)deltaX y:(CGFloat)deltaY duration:(F1t)sec;
+ (NKAction *)moveBy:(CGVector)delta duration:(F1t)sec;

+ (NKAction *)moveToX:(CGFloat)x y:(CGFloat)y duration:(F1t)sec;

+ (NKAction *)moveTo:(CGPoint)location duration:(F1t)sec;
+ (NKAction *)moveToX:(CGFloat)x duration:(F1t)sec;
+ (NKAction *)moveToY:(CGFloat)y duration:(F1t)sec;
//
+ (NKAction *)rotate3dToAngle:(V3t)angles duration:(F1t)sec;
+ (NKAction *)rotateByAngle:(CGFloat)radians duration:(F1t)sec;
+ (NKAction *)rotateToAngle:(CGFloat)radians duration:(F1t)sec;
+ (NKAction *)rotateToAngle:(CGFloat)radians duration:(F1t)sec shortestUnitArc:(BOOL)shortestUnitArc;
//
//+ (NKAction *)resizeByWidth:(CGFloat)width height:(CGFloat)height duration:(F1t)duration;
+ (NKAction *)resizeToWidth:(CGFloat)width height:(CGFloat)height duration:(F1t)duration;
//
//+ (NKAction *)resizeToWidth:(CGFloat)width duration:(F1t)duration;
//+ (NKAction *)resizeToHeight:(CGFloat)height duration:(F1t)duration;
//
+ (NKAction *)scaleBy:(CGFloat)scale duration:(F1t)sec;
+ (NKAction *)scaleXBy:(CGFloat)xScale y:(CGFloat)yScale duration:(F1t)sec;
+ (NKAction *)scaleTo:(CGFloat)scale duration:(F1t)sec;
+ (NKAction *)scaleXTo:(CGFloat)xScale y:(CGFloat)yScale duration:(F1t)sec;
+ (NKAction *)scaleXTo:(CGFloat)scale duration:(F1t)sec;
+ (NKAction *)scaleYTo:(CGFloat)scale duration:(F1t)sec;

+ (NKAction *)sequence:(NSArray *)actions;
+ (NKAction *)group:(NSArray *)actions;
+ (NKAction *)delayFor:(F1t)sec;

+ (NKAction *)repeatAction:(NKAction *)action count:(NSUInteger)count;
+ (NKAction *)repeatActionForever:(NKAction *)action;
//
//+ (NKAction *)fadeInWithDuration:(F1t)sec;
//+ (NKAction *)fadeOutWithDuration:(F1t)sec;
+ (NKAction *)fadeAlphaBy:(F1t)factor duration:(F1t)sec;
+ (NKAction *)fadeAlphaTo:(F1t)alpha duration:(F1t)sec;
//
//+ (NKAction *)setTexture:(ofTexture *)texture;
//+ (NKAction *)animateWithTextures:(NSArray *)textures timePerFrame:(F1t)sec;
//+ (NKAction *)animateWithTextures:(NSArray *)textures timePerFrame:(F1t)sec resize:(BOOL)resize restore:(BOOL)restore;
//
///* name must be the name or path of a file of a platform supported audio file format. Use a LinearPCM format audio file with 8 or 16 bits per channel for best performance */
//+ (NKAction *)playSoundFileNamed:(NSString*)soundFile waitForCompletion:(BOOL)wait;
//
//+ (NKAction *)colorizeWithColor:(UIColor *)color colorBlendFactor:(CGFloat)colorBlendFactor duration:(F1t)sec;
//+ (NKAction *)colorizeWithColorBlendFactor:(CGFloat)colorBlendFactor duration:(F1t)sec;
//
//+ (NKAction *)followPath:(CGPathRef)path duration:(F1t)sec;
//+ (NKAction *)followPath:(CGPathRef)path asOffset:(BOOL)offset orientToPath:(BOOL)orient duration:(F1t)sec;
//
//+ (NKAction *)speedBy:(CGFloat)speed duration:(F1t)sec;
//+ (NKAction *)speedTo:(CGFloat)speed duration:(F1t)sec;
//
//+ (NKAction *)waitForDuration:(F1t)sec;
//+ (NKAction *)waitForDuration:(F1t)sec withRange:(F1t)durationRange;
//
//+ (NKAction *)removeFromParent;
//
//+ (NKAction *)performSelector:(SEL)selector onTarget:(id)target;
//
//+ (NKAction *)runBlock:(dispatch_block_t)block;
//+ (NKAction *)runBlock:(dispatch_block_t)block queue:(dispatch_queue_t)queue;
//
//+ (NKAction *)runAction:(NKAction *)action onChildWithName:(NSString*)name;
//
+ (NKAction *)customActionWithDuration:(F1t)seconds actionBlock:(void (^)(NKNode *node, CGFloat elapsedTime))block;

// SCROLL NODE

+(NKAction*)scrollToPoint:(P2t)point duration:(F1t)sec;
+(NKAction*)scrollToChild:(NKNode*)child duration:(F1t)sec;

// GL UTILITY

+ (NKAction*)panTolookAtNode:(NKNode*)target duration:(F1t)sec;
+ (NKAction*)snapLookToNode:(NKNode*)target forDuration:(F1t)sec;

@end


@interface NKActionGroup : NSArray
@end


@interface NodeAnimationHandler : NSObject

{
    NSMutableArray *actions;
}

@property (nonatomic, weak) NodeAnimationHandler *handler;
@property (nonatomic) NKNode *node;

- (instancetype) initWithNode:(NKNode*)node;

- (void)updateWithTimeSinceLast:(F1t) dt;

- (void)runAction:(NKAction *)action;
- (void)runAction:(NKAction *)action completion:(void (^)())block;
- (void)runAction:(NKAction *)action withKey:(NSString *)key;

-(void)runCompletionBlockForAction:(NKAction*)action;

- (int)hasActions;
- (NKAction *)actionForKey:(NSString *)key;

- (void)removeActionForKey:(NSString *)key;
- (void)removeAllActions;

@end

