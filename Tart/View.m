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
        self.model = [[Model alloc] init];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (NSImage *)getTile:(CGPoint)tile {
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
    NSData *palette = [Fractal computePaletteWithGradient:gradient size:self.model.max gamma:self.model.gamma];
    NSData *data;
    @synchronized(self) {
        data = [Fractal clComputeTileDataWithMode:self.model.mode max:self.model.max zoom:self.model.zoom i:tile.x j:tile.y aa:self.model.aa jx:self.model.jx jy:self.model.jy];
    }
    return [Fractal computeTileImageWithData:data palette:palette];
}

- (void)drawRect:(NSRect)dirtyRect {
    CGSize size = self.bounds.size;
    CGPoint a = [self.model screenToTile:CGPointMake(0, size.height) size:size];
    CGPoint b = [self.model screenToTile:CGPointMake(size.width, 0) size:size];
    [NSBezierPath fillRect:dirtyRect];
    for (long j = a.y; j <= b.y; j++) {
        for (long i = a.x; i <= b.x; i++) {
            CGPoint point = [self.model tileToScreen:CGPointMake(i, j) size:size];
            NSRect dst = NSMakeRect(point.x, point.y, TILE_SIZE, TILE_SIZE);
            if (!CGRectIntersectsRect(dst, dirtyRect)) {
                continue;
            }
            NSImage *tile = [self getTile:CGPointMake(i, j)];
            if (tile) {
                [tile drawInRect:dst fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
                continue;
            }
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.bounds.size;
    if (event.clickCount % 2 == 0) {
        [self.model zoomInAtPoint:point size:size];
    }
    self.anchor = CGPointMake(self.model.x, self.model.y);
    self.dragPoint = point;
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.bounds.size;
    [self.model zoomOutAtPoint:point size:size];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    double dx = point.x - self.dragPoint.x;
    double dy = point.y - self.dragPoint.y;
    [self.model pan:CGPointMake(dx, dy) anchor:self.anchor];
    [self setNeedsDisplay:YES];
}

- (void)moveLeft:(id)sender {
    [self.model moveLeft];
    [self setNeedsDisplay:YES];
}

- (void)moveRight:(id)sender {
    [self.model moveRight];
    [self setNeedsDisplay:YES];
}

- (void)moveUp:(id)sender {
    [self.model moveUp];
    [self setNeedsDisplay:YES];
}

- (void)moveDown:(id)sender {
    [self.model moveDown];
    [self setNeedsDisplay:YES];
}

@end
