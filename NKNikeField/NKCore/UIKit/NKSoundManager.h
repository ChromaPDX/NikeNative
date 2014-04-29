//
//  NKSoundManager.h
//  NKNikeField
//
//  Created by Leif Shackelford on 4/29/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NKSoundManager : NSObject

-(void)loadSoundFileNamed:(NSString*)name;
-(void)playSoundFileNamed:(NSString*)name;

+ (NKSoundManager *)sharedInstance;

@property (nonatomic, strong) NSMutableDictionary *cachedSounds;

@end
