//
//  PlayerViewController.m
//  AudioPlayer
//
//  Created by mum on 2014/11/18.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController ()

@property (weak) IBOutlet NSButton *togglePlayingStatusButton;
@property (weak) IBOutlet NSSlider *seekBar;
@property (weak) IBOutlet NSSlider *rateSlider;
@property (weak) IBOutlet NSPopover *rateDisplay;
@property (weak) IBOutlet NSTextField *rateDisplayText;
@property (weak) IBOutlet NSTextField *timeElapsed;
@property (weak) IBOutlet NSTextField *timeLeft;

@property (nonatomic) Player* player;
@property (nonatomic) id periodicTimeObserver;

- (void)setup;

- (IBAction)onTogglePlayingStateClick:(id)sender;
- (IBAction)onSeekbarValueChanged:(id)sender;

- (void)handleAPMediaSelectedNotification:(NSNotification*)notification;

- (void)disableSeekBar;
- (void)enableSeekBar;
- (void)disableTogglePlayingStatusButton;
- (void)enableTogglePlayingStatusButton;
- (void)pause;
- (void)play;
- (void)applyPlayerItemStatus;

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
    self.player = [[Player alloc] init];

    // Subscribe media selection event
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAPMediaSelectedNotification:)
                                                 name:APMediaSelectedNotification
                                               object:nil];
    
    // Observe media load
    [self.player addObserver:self forKeyPath:@"isReadyToPlay" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
    
    [self initializeControls];
}

- (IBAction)onTogglePlayingStateClick:(id)sender {
    if (self.player.isReadyToPlay) {
        if ([self.player isPlaying]) {
            [self.player pause];
        }
        else {
            [self.player play];
            [self enableSeekBar];
        }
    }
}

- (IBAction)onSeekbarValueChanged:(id)sender {
    float newValue = [sender floatValue];
    if (self.player.isReadyToPlay) {
        [self.player seekToTime:CMTimeMake(newValue*self.player.currentItem.duration.timescale,
                                           self.player.currentItem.duration.timescale)];
    }
}

- (IBAction)onRateSliderValueChanged:(id)sender {
    float newValue = [sender floatValue];
    self.player.settingRate = newValue;
    self.rateDisplayText.stringValue = [NSString stringWithFormat:@"x%.2f", newValue];
    [self.rateDisplay showRelativeToRect:self.rateSlider.bounds ofView:self.rateSlider preferredEdge:NSMinYEdge];
}

- (void)handleAPMediaSelectedNotification:(NSNotification *)notification {
    NSURL* url = [notification userInfo][@"url"];
    if (url) {
        [self.player prepareToPlayWithUrl:url];
    }
}

- (void) initializeControls {
    self.rateSlider.floatValue = self.player.settingRate;
    [self disableSeekBar];
    [self disableTogglePlayingStatusButton];
}

- (void)enableSeekBar {
    if (self.player.isReadyToPlay) {
        self.seekBar.maxValue = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
        self.seekBar.enabled = YES;

        // Observe playing status
        __weak typeof(self) wself = self;
        double interval = ( 0.2f * self.seekBar.maxValue ) / self.seekBar.bounds.size.width;
        CMTime time     = CMTimeMakeWithSeconds(interval, NSEC_PER_SEC);

        self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time) {
            // update seekbar
            if (time.value != wself.player.currentItem.duration.value) {
                double duration = CMTimeGetSeconds([wself.player.currentItem duration]);
                double time     = CMTimeGetSeconds([wself.player currentTime]);
                float  value    = (wself.seekBar.maxValue - wself.seekBar.minValue ) * time / duration + wself.seekBar.minValue;
                wself.seekBar.floatValue = value;
                wself.timeElapsed.stringValue = [NSString stringWithFormat:@"%02.0f:%02.0f", floor([wself.player timeElapsedInSec]/60), floor(fmod([wself.player timeElapsedInSec], 60.0))];
                wself.timeLeft.stringValue = [NSString stringWithFormat:@"-%02.0f:%02.0f", floor([wself.player timeLeftInSec]/60), floor(fmod([wself.player timeLeftInSec], 60.0))];
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
    self.timeElapsed.stringValue = @"00:00";
    self.timeLeft.stringValue = @"-00:00";

    if (self.periodicTimeObserver != nil) {
        [self.player removeTimeObserver:self.periodicTimeObserver];
        self.periodicTimeObserver = nil;
    }
}

- (void)disableTogglePlayingStatusButton {
    self.togglePlayingStatusButton.enabled = NO;
}

- (void)enableTogglePlayingStatusButton {
    self.togglePlayingStatusButton.enabled = YES;
}

- (void)pause {
    [self.player pause];
    self.togglePlayingStatusButton.state = NSOffState;
}

- (void)play {
    [self.player play];
    self.togglePlayingStatusButton.enabled = NSOnState;
}

- (void)applyPlayerItemStatus {
    if (self.player.isReadyToPlay) {
        [self enableTogglePlayingStatusButton];
        [self enableSeekBar];
    }
    else {
        [self disableTogglePlayingStatusButton];
        [self disableSeekBar];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"isReadyToPlay"]) {
        [self applyPlayerItemStatus];
    }
    if([keyPath isEqualToString:@"currentItem"]) {
        [self initializeControls];
    }
}

@end
