//
//  JuliaPanel.h
//  Scale
//
//  Created by Michael Fogleman on 3/1/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StaticView.h"

@class View;

@interface JuliaPanel : NSPanel

@property (assign) IBOutlet View *fractalView;
@property (assign) IBOutlet StaticView *view;

@end
