//
//  NKSoundManager.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/29/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKSoundManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation NKSoundManager

static NKSoundManager *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        _cachedSounds = [NSMutableDictionary dictionary];
        NSLog(@"texture manager loaded");
    }
    
    return self;
}

+ (NKSoundManager *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}


-(void)loadSoundFileNamed:(NSString *)name {
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (path) {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AVAudioPlayer *soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:pathURL error:nil];
        if (soundPlayer) {
            [_cachedSounds setObject:soundPlayer forKey:@"name"];
            [soundPlayer prepareToPlay];
        }
    }
    else {
        NSLog(@"NKSoundManager failed to load sound");
    }

}

-(void)playSoundFileNamed:(NSString *)name {
    AVAudioPlayer *soundPlayer = [_cachedSounds objectForKey:name];
    if (soundPlayer) {
        if ([soundPlayer play]) {
            return;
        }
    }
    
    NSLog(@"NKSoundManager failed to play sound");

}

-(void)playSoundFileNamed:(NSString *)name completion:(void(^)())block {
    
}

@end
