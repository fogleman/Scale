//
//  AppDelegate.m
//  Scale
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)awakeFromNib {
    [self.window center];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    return;
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.allowedFileTypes = [NSArray arrayWithObjects:@"dat", nil];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSOKButton) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"library"];
            [data writeToURL:panel.URL atomically:NO];
        }
    }];
}

@end
