//
//  NKSoundManager.h
//  NKNikeField
//
//  Created by Leif Shackelford on 4/29/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKNode.h"
#import "NKNodeAnimationHandler.h"

@class NKSoundNode;

@interface NKSoundManager : NSObject

+(void)loadSoundFileNamed:(NSString*)name;
+(void)loadMultipleSoundFiles:(NSArray*)names;
+(void)loadAndPlayMusicNamed:(NSString*)name;

+(void)playSoundNamed:(NSString*)name;
+(void)playMusicNamed:(NSString*)name;

+ (NKSoundManager *)sharedInstance;
+ (void)updateWithTimeSinceLast:(F1t)dt;

@property (nonatomic, strong) NSMutableDictionary *cachedSounds;
@property (nonatomic,weak) NKSoundNode *currentPlayingMusic;

@end

@class AVAudioPlayer;

@interface NKSoundNode : NKNode
{
    AVAudioPlayer *player;
}

+(instancetype)soundWithName:(NSString*)name;

-(void)stop;
-(bool)play;
-(F1t)duration;
-(void)setVolume:(F1t)volume;
-(bool)isPlaying;

@end

@interface NKAction (NKSoundActions)

+(NKAction*)playSound;
+(NKAction*)fadeInSoundWithDuration:(F1t)sec;
+(NKAction*)fadeOutSoundWithDuration:(F1t)sec;

@end