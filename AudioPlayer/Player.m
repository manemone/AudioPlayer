//
//  Player.m
//  AudioPlayer
//
//  Created by kagetomo on 2014/11/20.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import "Player.h"

@interface Player()

@property (nonatomic, readwrite) BOOL isReadyToPlay;
@property (nonatomic) AVMutableAudioMix* settingAudioMix;

- (BOOL) checkIsReadyToPlay;
- (void) changePlayerItemWith:(AVPlayerItem*)item;
- (AVPlayerItem*) createNewPlayerItemWithUrl:(NSURL*)url;

@end

@implementation Player

- (Player*)init {
    if (self = [super init]) {
        AVMutableAudioMixInputParameters* mixParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
        mixParameters.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;

        self.settingAudioMix = [AVMutableAudioMix audioMix];
        self.settingAudioMix.inputParameters = @[mixParameters];

        self.settingRate = 1.2;
        
        // observe item's change
        [self addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"settingRate" options:NSKeyValueObservingOptionNew context:nil];
    }

    return self;
}

- (BOOL)checkIsReadyToPlay {
    if (self.status == AVPlayerStatusReadyToPlay && self.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.isReadyToPlay = YES;
    }
    else {
        self.isReadyToPlay = NO;
    }
    
    return self.isReadyToPlay;
}

- (BOOL)isPlaying {
    if (self.isReadyToPlay) {
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
    if (self.isReadyToPlay) {
        self.rate = self.settingRate;
    }
}

- (void) applyRateChange {
    if ([self isPlaying]) {
        self.rate = self.settingRate;
    }
}


- (void)playWithUrl:(NSURL*)url {
    [self prepareToPlayWithUrl:url];
    [self play];
}

- (void)prepareToPlayWithUrl:(NSURL*)url {
    if (self.isReadyToPlay) {
        [self pause];
        [self seekToTime:CMTimeMake(0, 1)];
    }

    AVPlayerItem* newItem = [self createNewPlayerItemWithUrl:url];
    [self changePlayerItemWith:newItem];
}

- (void) changePlayerItemWith:(AVPlayerItem*)item {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self replaceCurrentItemWithPlayerItem:item];
}

- (AVPlayerItem*) createNewPlayerItemWithUrl:(NSURL*)url {
    // Set audio content to the player
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    playerItem.audioMix = self.settingAudioMix;
    
    // Observe status change to update playing availability
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    return playerItem;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        [self checkIsReadyToPlay];
    }
    else if ([keyPath isEqualToString:@"currentItem"]) {
        [self checkIsReadyToPlay];
    }
    else if ([keyPath isEqualToString:@"settingRate"]) {
        [self applyRateChange];
    }
}

@end
