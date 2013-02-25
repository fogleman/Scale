//
//  View.h
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"

@interface View : NSView

@property (retain) Model *model;
@property (assign) CGPoint anchor;
@property (assign) CGPoint dragPoint;

@end
