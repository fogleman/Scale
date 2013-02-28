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
@property (assign) IBOutlet NSTextField *centerX;
@property (assign) IBOutlet NSTextField *centerY;
@property (assign) IBOutlet NSTextField *juliaX;
@property (assign) IBOutlet NSTextField *juliaY;

@end
