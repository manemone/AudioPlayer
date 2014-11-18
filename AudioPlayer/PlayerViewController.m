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

- (void)initializeAudioObjects;

- (IBAction)onTogglePlayingStateClick:(id)sender;

- (BOOL)isReadyToPlay;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)playWithUrl:(NSURL*)pathUrl;
- (void)disableSeekBar;
- (void)enableSeekBar;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeAudioObjects];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeAudioObjects];
}

- (void)initializeAudioObjects {
    AVMutableAudioMixInputParameters* mixParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
    mixParameters.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    
    self.audioMix = [AVMutableAudioMix audioMix];
    self.audioMix.inputParameters = @[mixParameters];
    
    self.player = [[AVPlayer alloc] init];
    
    self.playerRate = 1.2;
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
        
        // Observe playing status
        __weak typeof(self) wself = self;
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            // update seekbar
            if (time.value != wself.player.currentItem.duration.value) {
                wself.seekBar.floatValue = time.value/time.timescale;
            }
        }];
        
        NSArray* endOfItem = @[[NSValue valueWithCMTime:self.player.currentItem.duration]];
        [self.player addBoundaryTimeObserverForTimes:endOfItem queue:NULL usingBlock:^(void) {
            // reset playingStateToggleButton
            wself.togglePlayingStatusButton.state = NSOffState;
            
            [wself disableSeekBar];
        }];
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
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    // Show name of the selected content file
    NSArray *parts = [[url absoluteString] componentsSeparatedByString:@"/"];
    NSString *filename = [parts lastObject];
    NSLog(@"%@", filename);
    // self.selectedFileName.stringValue = filename;
}

- (void)enableSeekBar {
    if (self.player.currentItem) {
        self.seekBar.maxValue = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
        self.seekBar.enabled = YES;
    }
}

- (void)disableSeekBar {
    self.seekBar.minValue = 0.0;
    self.seekBar.floatValue = 0.0;
    self.seekBar.enabled = NO;
}

@end
