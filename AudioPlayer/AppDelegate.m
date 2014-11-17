//
//  AppDelegate.m
//  AudioPlayer
//
//  Created by mum on 2014/11/17.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property float playerRate;
@property (nonatomic) AVMutableAudioMix* audioMix;
@property (nonatomic) AVPlayer* player;
@property (weak) IBOutlet INAppStoreWindow *window;
@property (weak) IBOutlet NSTextField *selectedFileName;
@property (weak) IBOutlet NSView *titleView;
@property (weak) IBOutlet NSButton *togglePlayingStatusButton;
@property (weak) IBOutlet NSSlider *seekBar;

- (IBAction)onTogglePlayingStateClick:(id)sender;
- (IBAction)onOpenFileClick:(id)sender;

- (BOOL)isReadyToPlay;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)playWithUrl:(NSURL*)pathUrl;
- (void)prepareToPlayWithUrl:(NSURL*)pathUrl;
- (void)disableSeekBar;
- (void)enableSeekBar;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    AVMutableAudioMixInputParameters* mixParameters = [AVMutableAudioMixInputParameters audioMixInputParameters];
    mixParameters.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    
    self.audioMix = [AVMutableAudioMix audioMix];
    self.audioMix.inputParameters = @[mixParameters];
    
    self.player = [[AVPlayer alloc] init];
    
    self.playerRate = 1.2;
    
    self.window.titleBarHeight = 40.0;
    self.titleView.frame = self.window.titleBarView.bounds;
    self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.titleBarView addSubview:self.titleView];
    
    self.window.centerTrafficLightButtons = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)onTogglePlayingStateClick:(id)sender {
    if ([self isReadyToPlay]) {
        if ([self isPlaying]) {
            [self pause];
        }
        else {
            [self play];
        }
    }}

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
    
    self.selectedFileName.stringValue = filename;
}

- (IBAction)onOpenFileClick:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseDirectories = NO;
    openDlg.allowsMultipleSelection = NO;
    
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* theDoc = [[openDlg URLs] objectAtIndex:0];
            [self prepareToPlayWithUrl:theDoc];
        }
    }];
}

- (void)enableSeekBar {
    if (self.player.currentItem) {
        //NSLog(@"%lld", self.player.currentItem.duration.value);
        //NSLog(@"%d", self.player.currentItem.duration.timescale);
        self.seekBar.maxValue = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
        self.seekBar.floatValue = 0.0;
        self.seekBar.enabled = YES;
    }
}

- (void)disableSeekBar {
    self.seekBar.minValue = 0.0;
    self.seekBar.floatValue = 0.0;
    self.seekBar.enabled = NO;
}
@end
