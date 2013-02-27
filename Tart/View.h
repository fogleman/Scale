//
//  View.h
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cache.h"
#import "GradientPanel.h"
#import "InspectorPanel.h"
#import "Model.h"

@interface View : NSView

@property (retain) Model *model;
@property (retain) Cache *cache;
@property (assign) CGPoint anchor;
@property (assign) CGPoint dragPoint;

@property (assign) IBOutlet GradientPanel *gradientPanel;
@property (assign) IBOutlet InspectorPanel *inspectorPanel;

- (void)onGradient:(NSGradient *)gradient;
- (void)onGamma:(double)gamma;
- (void)onAntialiasing:(int)aa;
- (void)onInspector;

@end
