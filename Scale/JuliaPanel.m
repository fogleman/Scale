//
//  JuliaPanel.m
//  Scale
//
//  Created by Michael Fogleman on 3/1/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "JuliaPanel.h"
#import "Model.h"
#import "View.h"

@implementation JuliaPanel

- (void)awakeFromNib {
    [self setAcceptsMouseMovedEvents:YES];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]];
    self.view.model = [[[[[Model julia] withAntialiasing:1] withMax:256] withZoom:128] withGradient:gradient];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self.view convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.view.bounds.size;
    float jx = (point.x / size.width) * 3 - 1.5;
    float jy = (point.y / size.height) * 3 - 1.5;
    [self.fractalView onJuliaSeed:CGPointMake(jx, jy)];
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint point = [self.view convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.view.bounds.size;
    float jx = (point.x / size.width) * 3 - 1.5;
    float jy = (point.y / size.height) * 3 - 1.5;
    self.view.model = [self.view.model withJuliaSeed:CGPointMake(jx, jy)];
}

@end
