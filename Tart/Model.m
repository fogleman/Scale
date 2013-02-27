//
//  Model.m
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "Model.h"
#import "Common.h"
#import "Fractal.h"

@implementation Model

@synthesize palette = _palette;

+ (Model *)mandelbrot {
    Model *model = [[Model alloc] init];
    model.mode = MANDELBROT;
    model.max = INITIAL_DETAIL;
    model.zoom = INITIAL_ZOOM;
    model.x = -0.5;
    model.y = 0;
    model.aa = INITIAL_AA;
    model.jx = 0;
    model.jy = 0;
    model.gamma = INITIAL_GAMMA;
    model.gradient = nil;
    return model;
}

+ (Model *)julia {
    Model *model = [[Model alloc] init];
    model.mode = JULIA;
    model.max = INITIAL_DETAIL;
    model.zoom = INITIAL_ZOOM;
    model.x = 0;
    model.y = 0;
    model.aa = INITIAL_AA;
    model.jx = -0.4;
    model.jy = 0.6;
    model.gamma = INITIAL_GAMMA;
    model.gradient = nil;
    return model;
}

+ (Model *)random {
    Model *model = [[Model alloc] init];
    if (arc4random_uniform(2)) {
        CGPoint point = [Fractal randomMandelbrot];
        model.mode = MANDELBROT;
        model.x = point.x;
        model.y = point.y;
    }
    else {
        CGRect rect = [Fractal randomJulia];
        model.mode = JULIA;
        model.x = rect.origin.x;
        model.y = rect.origin.y;
        model.jx = rect.size.width;
        model.jy = rect.size.height;
    }
    model.max = RANDOM_DETAIL;
    model.zoom = pow(2, 12 + arc4random_uniform(10));
    model.aa = INITIAL_AA;
    model.gamma = INITIAL_GAMMA;
    model.gradient = nil;
    return model;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (Model *)copyWithZone:(NSZone *)zone {
    Model *model = [[[self class] alloc] init];
    if (model) {
        model.mode = self.mode;
        model.max = self.max;
        model.zoom = self.zoom;
        model.x = self.x;
        model.y = self.y;
        model.aa = self.aa;
        model.jx = self.jx;
        model.jy = self.jy;
        model.gamma = self.gamma;
        model.gradient = self.gradient;
        model.palette = self.palette;
    }
    return model;
}

- (BOOL)dataCompatible:(Model *)model {
    if (self.mode != model.mode) {
        return NO;
    }
    if (self.aa != model.aa) {
        return NO;
    }
    if (self.jx != model.jx) {
        return NO;
    }
    if (self.jy != model.jy) {
        return NO;
    }
    return YES;
}

- (BOOL)imageCompatible:(Model *)model {
    if (![self dataCompatible:model]) {
        return NO;
    }
    if (self.max != model.max) {
        return NO;
    }
    if (self.gamma != model.gamma) {
        return NO;
    }
    if (self.gradient != model.gradient) {
        return NO;
    }
    return YES;
}

- (CGPoint)tileToScreen:(CGPoint)point size:(CGSize)size center:(CGPoint)center zoom:(long)zoom {
    int x = size.width / 2 - center.x * zoom + point.x * TILE_SIZE;
    int y = size.height / 2 + center.y * zoom - point.y * TILE_SIZE - TILE_SIZE;
    return CGPointMake(x, y);
}

- (CGPoint)tileToScreen:(CGPoint)point size:(CGSize)size {
    CGPoint center = CGPointMake(self.x, self.y);
    return [self tileToScreen:point size:size center:center zoom:self.zoom];
}

- (CGPoint)screenToTile:(CGPoint)point size:(CGSize)size center:(CGPoint)center zoom:(long)zoom {
    double i = (point.x - size.width / 2 + center.x * zoom) / TILE_SIZE;
    double j = (point.y - size.height / 2 - center.y * zoom) / -TILE_SIZE;
    i = round(i - 0.5);
    j = round(j - 0.5);
    return CGPointMake(i, j);
}

- (CGPoint)screenToTile:(CGPoint)point size:(CGSize)size {
    CGPoint center = CGPointMake(self.x, self.y);
    return [self screenToTile:point size:size center:center zoom:self.zoom];
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

- (NSData *)palette {
    @synchronized (self) {
        if (_palette == nil) {
            _palette = [Fractal computePaletteWithGradient:self.gradient size:self.max gamma:self.gamma];
        }
        return _palette;
    }
}

- (Model *)withMandelbrot {
    Model *model = [self copy];
    model.mode = MANDELBROT;
    model.max = INITIAL_DETAIL;
    model.zoom = INITIAL_ZOOM;
    model.x = -0.5;
    model.y = 0;
    model.jx = 0;
    model.jy = 0;
    model.palette = nil;
    return model;
}

- (Model *)withJulia {
    CGPoint point = [Fractal randomMandelbrot];
    Model *model = [self copy];
    model.mode = JULIA;
    model.max = INITIAL_DETAIL;
    model.zoom = INITIAL_ZOOM;
    model.x = 0;
    model.y = 0;
    model.jx = point.x;
    model.jy = point.y;
    model.palette = nil;
    return model;
}

- (Model *)withRandom {
    Model *model = [self copy];
    if (arc4random_uniform(2)) {
        CGPoint point = [Fractal randomMandelbrot];
        model.mode = MANDELBROT;
        model.x = point.x;
        model.y = point.y;
    }
    else {
        CGRect rect = [Fractal randomJulia];
        model.mode = JULIA;
        model.x = rect.origin.x;
        model.y = rect.origin.y;
        model.jx = rect.size.width;
        model.jy = rect.size.height;
    }
    model.max = RANDOM_DETAIL;
    model.zoom = pow(2, 12 + arc4random_uniform(10));
    model.palette = nil;
    return model;
}

- (Model *)withCenter:(CGPoint)point {
    Model *model = [self copy];
    model.x = point.x;
    model.y = point.y;
    return model;
}

- (Model *)withJuliaSeed:(CGPoint)point {
    Model *model = [self copy];
    model.jx = point.x;
    model.jy = point.y;
    return model;
}

- (Model *)withMax:(int)max {
    Model *model = [self copy];
    model.max = max;
    model.palette = nil;
    return model;
}

- (Model *)withZoom:(long)zoom {
    Model *model = [self copy];
    model.zoom = zoom;
    return model;
}

- (Model *)withGradient:(NSGradient *)gradient {
    Model *model = [self copy];
    model.gradient = gradient;
    model.palette = nil;
    return model;
}

- (Model *)withGamma:(double)gamma {
    Model *model = [self copy];
    model.gamma = gamma;
    model.palette = nil;
    return model;
}

- (Model *)withAntialiasing:(int)aa {
    Model *model = [self copy];
    model.aa = aa;
    return model;
}

- (Model *)moreDetail {
    Model *model = [self copy];
    model.max = MIN(self.max * 2, MAX_DETAIL);
    model.palette = nil;
    return model;
}

- (Model *)lessDetail {
    Model *model = [self copy];
    model.max = MAX(self.max / 2, MIN_DETAIL);
    model.palette = nil;
    return model;
}

- (Model *)zoomIn {
    Model *model = [self copy];
    model.zoom = MIN(self.zoom * 2, MAX_ZOOM);
    return model;
}

- (Model *)zoomInAtPoint:(CGPoint)point size:(CGSize)size {
    Model *model = [self copy];
    CGPoint p = [model screenToPoint:point size:size];
    model.zoom = MIN(self.zoom * 2, MAX_ZOOM);
    CGPoint q = [model screenToPoint:point size:size];
    double dx = q.x - p.x;
    double dy = q.y - p.y;
    model.x -= dx;
    model.y += dy;
    return model;
}

- (Model *)zoomOut {
    Model *model = [self copy];
    model.zoom = MAX(self.zoom / 2, MIN_ZOOM);
    return model;
}

- (Model *)zoomOutAtPoint:(CGPoint)point size:(CGSize)size {
    Model *model = [self copy];
    CGPoint p = [model screenToPoint:point size:size];
    model.zoom = MAX(self.zoom / 2, MIN_ZOOM);
    CGPoint q = [model screenToPoint:point size:size];
    double dx = q.x - p.x;
    double dy = q.y - p.y;
    model.x -= dx;
    model.y += dy;
    return model;
}

- (Model *)pan:(CGPoint)offset anchor:(CGPoint)anchor {
    Model *model = [self copy];
    model.x = anchor.x - offset.x / model.zoom;
    model.y = anchor.y + offset.y / model.zoom;
    return model;
}

- (Model *)moveLeft {
    Model *model = [self copy];
    model.x -= (double)PAN_FACTOR / model.zoom;
    return model;
}

- (Model *)moveRight {
    Model *model = [self copy];
    model.x += (double)PAN_FACTOR / model.zoom;
    return model;
}

- (Model *)moveUp {
    Model *model = [self copy];
    model.y += (double)PAN_FACTOR / model.zoom;
    return model;
}

- (Model *)moveDown {
    Model *model = [self copy];
    model.y -= (double)PAN_FACTOR / model.zoom;
    return model;
}

- (void)setMode:(int)mode {
    _mode = mode;
}

- (void)setMax:(int)max {
    _max = max;
}

- (void)setZoom:(long)zoom {
    _zoom = zoom;
}

- (void)setX:(double)x {
    _x = x;
}

- (void)setY:(double)y {
    _y = y;
}

- (void)setAa:(int)aa {
    _aa = aa;
}

- (void)setJx:(double)jx {
    _jx = jx;
}

- (void)setJy:(double)jy {
    _jy = jy;
}

- (void)setGamma:(double)gamma {
    _gamma = gamma;
}

- (void)setGradient:(NSGradient *)gradient {
    _gradient = gradient;
}

- (void)setPalette:(NSData *)palette {
    _palette = palette;
}

@end
