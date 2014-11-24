//
//  Player.h
//  AudioPlayer
//
//  Created by kagetomo on 2014/11/20.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "APNotification.h"

@interface Player : AVPlayer

@property (nonatomic, readonly) BOOL isReadyToPlay;
@property float settingRate;

- (BOOL)isPlaying;
- (void)prepareToPlayWithUrl:(NSURL*)pathUrl;
- (void)playWithUrl:(NSURL*)pathUrl;

@end
