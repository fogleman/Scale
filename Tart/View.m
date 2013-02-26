//
//  View.m
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "View.h"
#import "Common.h"
#import "Fractal.h"

@implementation View

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *colors = [NSArray arrayWithObjects:[Common color:0x580022], [Common color:0xAA2C30], [Common color:0xFFBE8D], [Common color:0x487B7F], [Common color:0x011D24], nil];
        NSGradient *gradient = [[NSGradient alloc] initWithColors:colors];
        self.model = [[Model mandelbrot] withGradient:gradient];
        self.cache = [[Cache alloc] initWithView:self];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.cache setModel:self.model size:self.bounds.size];
    CGSize size = self.bounds.size;
    CGPoint a = [self.model screenToTile:CGPointMake(0, size.height) size:size];
    CGPoint b = [self.model screenToTile:CGPointMake(size.width, 0) size:size];
    [NSBezierPath fillRect:dirtyRect];
    NSDictionary *hints = [NSDictionary dictionaryWithObject:@(NSImageInterpolationNone) forKey:NSImageHintInterpolation];
    for (long j = a.y; j <= b.y; j++) {
        for (long i = a.x; i <= b.x; i++) {
            CGPoint point = [self.model tileToScreen:CGPointMake(i, j) size:size];
            NSRect dst = NSMakeRect(point.x, point.y, TILE_SIZE, TILE_SIZE);
            if (!CGRectIntersectsRect(dst, dirtyRect)) {
                continue;
            }
            NSImage *tile = [self.cache getTileWithZoom:self.model.zoom i:i j:j];
            if (tile) {
                [tile drawInRect:dst fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
                continue;
            }
            for (long m = 2; m <= 8; m *= 2) {
                long zoom = self.model.zoom / m;
                long p = floor((double)i / m);
                long q = floor((double)j / m);
                tile = [self.cache getTileWithZoom:zoom i:p j:q];
                if (tile) {
                    long size = TILE_SIZE / m;
                    long dx = i % m;
                    long dy = j % m;
                    dx = dx < 0 ? dx + m : dx;
                    dy = dy < 0 ? dy + m : dy;
                    NSRect src = NSMakeRect(dx * size, dy * size, size, size);
                    [tile drawInRect:dst fromRect:src operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:hints];
                    break;
                }
            }
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.bounds.size;
    if (event.clickCount % 2 == 0) {
        self.model = [self.model zoomInAtPoint:point size:size];
    }
    self.anchor = CGPointMake(self.model.x, self.model.y);
    self.dragPoint = point;
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.bounds.size;
    self.model = [self.model zoomOutAtPoint:point size:size];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    double dx = point.x - self.dragPoint.x;
    double dy = point.y - self.dragPoint.y;
    self.model = [self.model pan:CGPointMake(dx, dy) anchor:self.anchor];
    [self setNeedsDisplay:YES];
}

- (void)moveLeft:(id)sender {
    self.model = [self.model moveLeft];
    [self setNeedsDisplay:YES];
}

- (void)moveRight:(id)sender {
    self.model = [self.model moveRight];
    [self setNeedsDisplay:YES];
}

- (void)moveUp:(id)sender {
    self.model = [self.model moveUp];
    [self setNeedsDisplay:YES];
}

- (void)moveDown:(id)sender {
    self.model = [self.model moveDown];
    [self setNeedsDisplay:YES];
}

- (IBAction)onZoomIn:(id)sender {
    self.model = [self.model zoomIn];
    [self setNeedsDisplay:YES];
}

- (IBAction)onZoomOut:(id)sender {
    self.model = [self.model zoomOut];
    [self setNeedsDisplay:YES];
}

- (IBAction)onMoreDetail:(id)sender {
    self.model = [self.model moreDetail];
    [self setNeedsDisplay:YES];
}

- (IBAction)onLessDetail:(id)sender {
    self.model = [self.model lessDetail];
    [self setNeedsDisplay:YES];
}

@end
