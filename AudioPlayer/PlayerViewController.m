//
//  PlayerViewController.m
//  AudioPlayer
//
//  Created by mum on 2014/11/18.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController ()

@property float playerRate;
@property (nonatomic) AVMutableAudioMix* audioMix;
@property (nonatomic) AVPlayer* player;
@property (weak) IBOutlet NSButton *togglePlayingStatusButton;
@property (weak) IBOutlet NSSlider *seekBar;
@property (nonatomic) id periodicTimeObserver;

- (void)setup;

- (IBAction)onTogglePlayingStateClick:(id)sender;
- (IBAction)onSeekbarValueChanged:(id)sender;

- (BOOL)isReadyToPlay;
- (BOOL)isPlaying;
- (void)prepareToPlayWithUrl:(NSURL*)pathUrl;
- (void)play;
- (void)pause;
- (void)playWithUrl:(NSURL*)pathUrl;
- (void)disableSeekBar;
- (void)enableSeekBar;

- (void)handleAPMediaSelectedNotification:(NSNotification*)notification;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    AVMutableAudioMixInputParameters* mixParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
    mixParameters.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    
    self.audioMix = [AVMutableAudioMix audioMix];
    self.audioMix.inputParameters = @[mixParameters];
    
    self.player = [[AVPlayer alloc] init];
    
    self.playerRate = 1.2;
    
    // Subscribe media selection event
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAPMediaSelectedNotification:)
                                                 name:APMediaSelectedNotification
                                               object:nil];
}

- (IBAction)onTogglePlayingStateClick:(id)sender {
    if ([self isReadyToPlay]) {
        if ([self isPlaying]) {
            [self pause];
        }
        else {
            [self play];
        }
    }
}

- (IBAction)onSeekbarValueChanged:(id)sender {
    float newValue = [sender floatValue];
    if (self.isReadyToPlay) {
        [self.player seekToTime:CMTimeMake(newValue*self.player.currentItem.duration.timescale,
                                           self.player.currentItem.duration.timescale)];
    }
}

- (BOOL)isReadyToPlay {
    if (self.player != nil && self.player.status == AVPlayerStatusReadyToPlay) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isPlaying {
    if ([self isReadyToPlay]) {
        if (!self.player.error) {
            if (self.player.rate != 0) {
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
        self.player.rate = self.playerRate;
        self.togglePlayingStatusButton.state = NSOnState;
        
        [self enableSeekBar];
    }
}

- (void)pause {
    if ([self isReadyToPlay]) {
        [self.player pause];
    }
    self.togglePlayingStatusButton.state = NSOffState;
}

- (void)playWithUrl:(NSURL*)url {
    [self prepareToPlayWithUrl:url];
    [self play];
}

- (void)prepareToPlayWithUrl:(NSURL*)url {
    [self pause];
    [self.player seekToTime:CMTimeMake(0, 1)];
    
    // Set audio content to the player
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    playerItem.audioMix = self.audioMix;
    
    // disable seekbar
    [self disableSeekBar];
    
    self.togglePlayingStatusButton.enabled = YES;
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)enableSeekBar {
    if (self.player.currentItem) {
        self.seekBar.maxValue = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
        self.seekBar.enabled = YES;
        
        // Observe playing status
        __weak typeof(self) wself = self;
        double interval = ( 0.5f * self.seekBar.maxValue ) / self.seekBar.bounds.size.width;
        CMTime time     = CMTimeMakeWithSeconds( interval, NSEC_PER_SEC );
        
        self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time) {
            // update seekbar
            if (time.value != wself.player.currentItem.duration.value) {
                double duration = CMTimeGetSeconds([wself.player.currentItem duration]);
                double time     = CMTimeGetSeconds([wself.player currentTime]);
                float  value    = (wself.seekBar.maxValue - wself.seekBar.minValue ) * time / duration + wself.seekBar.minValue;
                wself.seekBar.floatValue = value;
            }
            else {
                [wself pause];
                [wself.player seekToTime:CMTimeMake(0, 1)];
            }
        }];
    }
}

- (void)disableSeekBar {
    self.seekBar.minValue = 0.0;
    self.seekBar.floatValue = 0.0;
    self.seekBar.enabled = NO;
    
    if (self.periodicTimeObserver != nil) {
        [self.player removeTimeObserver:self.periodicTimeObserver];
        self.periodicTimeObserver = nil;
    }
}

- (void)handleAPMediaSelectedNotification:(NSNotification *)notification {
    NSURL* url = [notification userInfo][@"url"];
    if (url) {
        [self prepareToPlayWithUrl:url];
    }
}

@end
