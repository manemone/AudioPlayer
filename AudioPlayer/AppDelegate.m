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
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *selectedFileName;

- (IBAction)onPlayClick:(id)sender;
- (IBAction)onPauseClick:(id)sender;
- (IBAction)onOpenFileClick:(id)sender;

- (BOOL)isReadyToPlay;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)playWithUrl:(NSURL*)pathUrl;
- (void)prepareToPlayWithUrl:(NSURL*)pathUrl;
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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)onPlayClick:(id)sender {
    [self play];
}

- (IBAction)onPauseClick:(id)sender {
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
    }
}

- (void)pause {
    if ([self isReadyToPlay]) {
        [self.player pause];
    }
}

- (void)playWithUrl:(NSURL*)url {
    [self prepareToPlayWithUrl:url];
    [self play];
}

- (void)prepareToPlayWithUrl:(NSURL*)url {
    if ([self isReadyToPlay]) {
        [self.player pause];
    }
    
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    playerItem.audioMix = self.audioMix;
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
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
            [self playWithUrl:theDoc];
        }
    }];
}
@end
