//
//  Player.m
//  AudioPlayer
//
//  Created by kagetomo on 2014/11/20.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import "Player.h"

@interface Player()

@property float settingRate;
@property (nonatomic) AVMutableAudioMix* settingAudioMix;

@end

@implementation Player

- (Player*)init {
    if (self = [super init]) {
        AVMutableAudioMixInputParameters* mixParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
        mixParameters.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;

        self.settingAudioMix = [AVMutableAudioMix audioMix];
        self.settingAudioMix.inputParameters = @[mixParameters];

        self.settingRate = 1.2;
    }

    return self;
}

- (BOOL)isReadyToPlay {
    if (self != nil && self.status == AVPlayerStatusReadyToPlay) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isPlaying {
    if ([self isReadyToPlay]) {
        if (!self.error) {
            if (self.rate != 0) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (void)play {
    if ([self isReadyToPlay]) {
        self.rate = self.settingRate;
    }
}


- (void)playWithUrl:(NSURL*)url {
    [self prepareToPlayWithUrl:url];
    [self play];
}

- (void)prepareToPlayWithUrl:(NSURL*)url {
    if ([self isReadyToPlay]) {
        [self pause];
        [self seekToTime:CMTimeMake(0, 1)];
    }

    // Set audio content to the player
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    playerItem.audioMix = self.settingAudioMix;

    [self replaceCurrentItemWithPlayerItem:playerItem];
}

@end
