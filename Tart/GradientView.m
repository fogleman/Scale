//
//  GradientView.m
//  Fractals
//
//  Created by Michael Fogleman on 2/20/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (void)dealloc {
    self.gradient = nil;
}

- (void)drawRect:(NSRect)dirtyRect {
    CGSize size = self.bounds.size;
    [[NSColor blackColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0, 0, size.width, size.height)];
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(1, 1, size.width - 2, size.height - 2)];
    [NSBezierPath clipRect:NSMakeRect(2, 2, size.width - 4, size.height - 4)];
    CGPoint a = CGPointMake(0, 0);
    CGPoint b = CGPointMake(self.bounds.size.width, 0);
    [self.gradient drawFromPoint:a toPoint:b options:0];
}

@end
