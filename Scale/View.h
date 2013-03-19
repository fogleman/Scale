//
//  View.h
//  Scale
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cache.h"
#import "GradientPanel.h"
#import "InspectorPanel.h"
#import "JuliaPanel.h"
#import "LibraryPanel.h"
#import "Model.h"

@interface View : NSView

@property (retain) Model *model;
@property (retain) Cache *cache;
@property (assign) CGPoint anchor;
@property (assign) CGPoint dragPoint;
@property (assign) BOOL cancelSave;

@property (assign) IBOutlet GradientPanel *gradientPanel;
@property (assign) IBOutlet InspectorPanel *inspectorPanel;
@property (assign) IBOutlet JuliaPanel *juliaPanel;
@property (assign) IBOutlet LibraryPanel *libraryPanel;
@property (assign) IBOutlet NSView *saveAccessoryView;
@property (assign) IBOutlet NSTextField *saveWidth;
@property (assign) IBOutlet NSTextField *saveHeight;
@property (assign) IBOutlet NSPopUpButton *saveAntialiasing;
@property (assign) IBOutlet NSWindow *saveProgressWindow;
@property (assign) IBOutlet NSProgressIndicator *saveProgressIndicator;

- (void)onGradient:(NSGradient *)gradient;
- (void)onGamma:(double)gamma;
- (void)onAntialiasing:(int)aa;
- (void)onInspector;
- (void)onJuliaSeed:(CGPoint)seed;
- (void)onLibraryModel:(Model *)model;

@end
