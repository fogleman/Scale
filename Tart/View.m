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

- (void)dealloc {
    self.model = nil;
    self.cache = nil;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)updateLabels {
    self.inspectorPanel.centerX.doubleValue = self.model.x;
    self.inspectorPanel.centerY.doubleValue = self.model.y;
    self.inspectorPanel.zoom.doubleValue = log(self.model.zoom) / log(2);
    self.inspectorPanel.detail.doubleValue = log(self.model.max) / log(2);
    if (self.model.mode == JULIA) {
        self.inspectorPanel.juliaX.doubleValue = self.model.jx;
        self.inspectorPanel.juliaY.doubleValue = self.model.jy;
        [self.inspectorPanel.juliaX setEnabled:YES];
        [self.inspectorPanel.juliaY setEnabled:YES];
    }
    else {
        self.inspectorPanel.juliaX.stringValue = @"";
        self.inspectorPanel.juliaY.stringValue = @"";
        [self.inspectorPanel.juliaX setEnabled:NO];
        [self.inspectorPanel.juliaY setEnabled:NO];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [self updateLabels];
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

- (IBAction)onColors:(id)sender {
    if (!self.gradientPanel.isVisible) {
        [self.gradientPanel makeKeyAndOrderFront:nil];
    }
    else {
        [self.gradientPanel orderOut:nil];
    }
}

- (IBAction)onInspector:(id)sender {
    if (!self.inspectorPanel.isVisible) {
        [self.inspectorPanel makeKeyAndOrderFront:nil];
    }
    else {
        [self.inspectorPanel orderOut:nil];
    }
}

- (void)onGradient:(NSGradient *)gradient {
    self.model = [self.model withGradient:gradient];
    [self setNeedsDisplay:YES];
}

- (void)onGamma:(double)gamma {
    self.model = [self.model withGamma:gamma];
    [self setNeedsDisplay:YES];
}

- (void)onAntialiasing:(int)aa {
    self.model = [self.model withAntialiasing:aa];
    [self setNeedsDisplay:YES];
}

- (void)onInspector {
    self.model = [self.model withCenter:CGPointMake(self.inspectorPanel.centerX.doubleValue, self.inspectorPanel.centerY.doubleValue)];
    self.model = [self.model withJulia:CGPointMake(self.inspectorPanel.juliaX.doubleValue, self.inspectorPanel.juliaY.doubleValue)];
    self.model = [self.model withZoom:pow(2, self.inspectorPanel.zoom.intValue)];
    self.model = [self.model withMax:pow(2, self.inspectorPanel.detail.doubleValue)];
    [self setNeedsDisplay:YES];
}

@end
