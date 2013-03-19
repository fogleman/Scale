//
//  GradientPanel.h
//  Fractals
//
//  Created by Michael Fogleman on 2/20/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GradientView.h"

@class View;

@interface GradientPanel : NSPanel

@property (assign) IBOutlet View *fractalView;
@property (assign) IBOutlet GradientView *gradientView;
@property (assign) IBOutlet NSPopUpButton *presetsButton;
@property (retain) NSMutableArray *checkBoxes;
@property (retain) NSMutableArray *colorWells;
@property (retain) NSMutableArray *sliders;
@property (retain) NSMutableArray *names;
@property (retain) NSMutableArray *gradients;

- (void)setGradient:(NSGradient *)gradient;

@end
