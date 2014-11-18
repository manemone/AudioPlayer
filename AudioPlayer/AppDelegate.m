//
//  AppDelegate.m
//  AudioPlayer
//
//  Created by mum on 2014/11/17.
//  Copyright (c) 2014年 menemone.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet INAppStoreWindow *window;
@property (weak) IBOutlet NSTextField *selectedFileName;
@property (weak) IBOutlet PlayerViewController *playerViewController;

- (IBAction)onOpenFileClick:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    self.window.titleBarHeight = 40.0;
    self.playerViewController.playerView.frame = self.window.titleBarView.bounds;
    self.playerViewController.playerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.titleBarView addSubview:self.playerViewController.playerView];
    
    self.window.centerTrafficLightButtons = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)onOpenFileClick:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseDirectories = NO;
    openDlg.allowsMultipleSelection = NO;
    
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* theDoc = [[openDlg URLs] objectAtIndex:0];
            [self.playerViewController prepareToPlayWithUrl:theDoc];
        }
    }];
}

@end
