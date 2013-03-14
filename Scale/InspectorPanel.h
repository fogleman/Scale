//
//  InspectorPanel.h
//  Fractals
//
//  Created by Michael Fogleman on 2/21/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class View;

@interface InspectorPanel : NSPanel

@property (assign) IBOutlet View *fractalView;
@property (assign) IBOutlet NSSegmentedControl *mode;
@property (assign) IBOutlet NSTextField *centerX;
@property (assign) IBOutlet NSTextField *centerY;
@property (assign) IBOutlet NSTextField *juliaX;
@property (assign) IBOutlet NSTextField *juliaY;
@property (assign) IBOutlet NSSlider *zoomSlider;
@property (assign) IBOutlet NSTextField *zoomTextField;
@property (assign) IBOutlet NSStepper *zoomStepper;
@property (assign) IBOutlet NSSlider *detailSlider;
@property (assign) IBOutlet NSTextField *detailTextField;
@property (assign) IBOutlet NSStepper *detailStepper;
@property (assign) IBOutlet NSSlider *exponentSlider;
@property (assign) IBOutlet NSTextField *exponentTextField;
@property (assign) IBOutlet NSStepper *exponentStepper;

@end
