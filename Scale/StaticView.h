//
//  StaticView.h
//  Scale
//
//  Created by Michael Fogleman on 3/1/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"

@interface StaticView : NSView

@property (retain, nonatomic) Model *model;

@end
