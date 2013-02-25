//
//  Model.m
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "Model.h"
#import "Common.h"

@implementation Model

- (id)init {
    self = [super init];
    if (self) {
        [self mandelbrot];
    }
    return self;
}

- (void)mandelbrot {
    self.mode = MANDELBROT;
    self.max = INITIAL_DETAIL;
    self.zoom = INITIAL_ZOOM;
    self.x = -0.5;
    self.y = 0;
    self.aa = INITIAL_AA;
    self.jx = 0;
    self.jy = 0;
    self.gamma = INITIAL_GAMMA;
}

- (void)julia {
    self.mode = JULIA;
    self.max = INITIAL_DETAIL;
    self.zoom = INITIAL_ZOOM;
    self.x = 0;
    self.y = 0;
    self.aa = INITIAL_AA;
    self.jx = 0.285;
    self.jy = 0.01;
    self.gamma = INITIAL_GAMMA;
}

- (CGPoint)tileToScreen:(CGPoint)point center:(CGPoint)center size:(CGSize)size zoom:(long)zoom {
    int x = size.width / 2 - center.x * zoom + point.x * TILE_SIZE;
    int y = size.height / 2 + center.y * zoom - point.y * TILE_SIZE - TILE_SIZE;
    return CGPointMake(x, y);
}

- (CGPoint)tileToScreen:(CGPoint)point size:(CGSize)size {
    CGPoint center = CGPointMake(self.x, self.y);
    return [self tileToScreen:point center:center size:size zoom:self.zoom];
}

- (CGPoint)screenToTile:(CGPoint)point center:(CGPoint)center size:(CGSize)size zoom:(long)zoom {
    double i = (point.x - size.width / 2 + center.x * zoom) / TILE_SIZE;
    double j = (point.y - size.height / 2 - center.y * zoom) / -TILE_SIZE;
    i = round(i - 0.5);
    j = round(j - 0.5);
    return CGPointMake(i, j);
}

- (CGPoint)screenToTile:(CGPoint)point size:(CGSize)size {
    CGPoint center = CGPointMake(self.x, self.y);
    return [self screenToTile:point center:center size:size zoom:self.zoom];
}

- (CGPoint)pointToScreen:(CGPoint)point size:(CGSize)size {
    int x = (point.x - self.x) * self.zoom + size.width / 2;
    int y = (point.y - self.y) * self.zoom + size.height / 2;
    return CGPointMake(x, y);
}

- (CGPoint)screenToPoint:(CGPoint)point size:(CGSize)size {
    double x = self.x + (point.x - size.width / 2) / self.zoom;
    double y = self.y + (point.y - size.height / 2) / self.zoom;
    return CGPointMake(x, y);
}

- (void)zoomIn {
    self.zoom *= 2;
    self.zoom = MIN(self.zoom, MAX_ZOOM);
}

- (void)zoomInAtPoint:(CGPoint)point size:(CGSize)size {
    CGPoint p = [self screenToPoint:point size:size];
    [self zoomIn];
    CGPoint q = [self screenToPoint:point size:size];
    double dx = q.x - p.x;
    double dy = q.y - p.y;
    self.x -= dx;
    self.y += dy;
}

- (void)zoomOut {
    self.zoom /= 2;
    self.zoom = MAX(self.zoom, MIN_ZOOM);
}

- (void)zoomOutAtPoint:(CGPoint)point size:(CGSize)size {
    CGPoint p = [self screenToPoint:point size:size];
    [self zoomOut];
    CGPoint q = [self screenToPoint:point size:size];
    double dx = q.x - p.x;
    double dy = q.y - p.y;
    self.x -= dx;
    self.y += dy;
}

- (void)moveLeft {
    self.x -= (double)PAN_FACTOR / self.zoom;
}

- (void)moveRight {
    self.x += (double)PAN_FACTOR / self.zoom;
}

- (void)moveUp {
    self.y += (double)PAN_FACTOR / self.zoom;
}

- (void)moveDown {
    self.y -= (double)PAN_FACTOR / self.zoom;
}

@end
