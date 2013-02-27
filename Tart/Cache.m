//
//  Cache.m
//  Tart
//
//  Created by Michael Fogleman on 2/25/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "Cache.h"
#import "Common.h"
#import "Fractal.h"
#import "View.h"

#define UNPACK(x, i) (((NSNumber *)[(x) objectAtIndex:(i)]).integerValue)

@implementation Cache

- (id)initWithView:(View *)view {
    self = [super init];
    if (self) {
        self.model = nil;
        self.view = view;
        self.seen = [NSMutableOrderedSet orderedSet];
        self.dataCache = [NSMutableDictionary dictionary];
        self.maxCache = [NSMutableDictionary dictionary];
        self.imageCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.model = nil;
    self.view = nil;
    self.seen = nil;
    self.dataCache = nil;
    self.maxCache = nil;
    self.imageCache = nil;
}

- (NSImage *)getTileWithZoom:(long)zoom i:(long)i j:(long)j {
    NSArray *key = [NSArray arrayWithObjects:@(i), @(j), @(zoom), nil];
    return [self.imageCache objectForKey:key];
}

- (void)setModel:(Model *)model size:(CGSize)size {
    if (model == self.model && size.width == self.size.width && size.height == self.size.height) {
        return;
    }
    if (![model dataCompatible:self.model]) {
        [self.seen removeAllObjects];
        [self.dataCache removeAllObjects];
        [self.maxCache removeAllObjects];
        [self.imageCache removeAllObjects];
    }
    if (![model imageCompatible:self.model]) {
        [self.seen removeAllObjects];
    }
    self.model = model;
    self.size = size;
    self.a = [model screenToTile:CGPointMake(0, size.height) size:size];
    self.b = [model screenToTile:CGPointMake(size.width, 0) size:size];
//    int n = INITIAL_ZOOM / TILE_SIZE * 2;
//    int m = -(n + 1);
//    CGPoint a = CGPointMake(m, m);
//    CGPoint b = CGPointMake(n, n);
//    [self ensureKeysWithZoom:INITIAL_ZOOM a:a b:b];
    [self ensureKeysWithZoom:self.model.zoom a:self.a b:self.b];
}

- (void)ensureKeysWithZoom:(long)zoom a:(CGPoint)a b:(CGPoint)b {
    NSMutableArray *keys = [NSMutableArray array];
    for (long j = a.y; j <= b.y; j++) {
        for (long i = a.x; i <= b.x; i++) {
            NSArray *key = [NSArray arrayWithObjects:@(i), @(j), @(zoom), nil];
            [keys addObject:key];
        }
    }
    [Common shuffleArray:keys];
    for (NSArray *key in keys) {
        [self ensureKey:key];
    }
}

- (BOOL)isKeyStale:(NSArray *)key {
    long i = UNPACK(key, 0);
    long j = UNPACK(key, 1);
    long zoom = UNPACK(key, 2);
//    if (zoom == INITIAL_ZOOM) {
//        return NO;
//    }
    if (zoom != self.model.zoom) {
        return YES;
    }
    if (i < self.a.x || i > self.b.x) {
        return YES;
    }
    if (j < self.a.y || j > self.b.y) {
        return YES;
    }
    return NO;
}

- (void)ensureKey:(NSArray *)key {
    if ([self.seen containsObject:key]) {
        return;
    }
    [self.seen addObject:key];
    long i = UNPACK(key, 0);
    long j = UNPACK(key, 1);
    long zoom = UNPACK(key, 2);
    Model *model = self.model;
    NSData *cachedData = [self.dataCache objectForKey:key];
    int cachedMax = ((NSNumber *)[self.maxCache objectForKey:key]).intValue;
    if (cachedData && cachedMax >= model.max) {
        NSImage *image = [Fractal computeTileImageWithData:cachedData palette:model.palette];
        [self.imageCache setObject:image forKey:key];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([self isKeyStale:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.seen removeObject:key];
                [self.view setNeedsDisplay:YES];
            });
            return;
        }
        NSData *data = [Fractal computeTileDataWithMode:model.mode max:model.max zoom:zoom i:i j:j aa:model.aa jx:model.jx jy:model.jy ref:cachedData];
        NSImage *image = [Fractal computeTileImageWithData:data palette:model.palette];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([model dataCompatible:self.model]) {
                [self.dataCache setObject:data forKey:key];
                [self.maxCache setObject:@(model.max) forKey:key];
            }
            else {
                [self.seen removeObject:key];
            }
            if ([model imageCompatible:self.model]) {
                [self.imageCache setObject:image forKey:key];
            }
            else {
                [self.seen removeObject:key];
            }
            [self.view setNeedsDisplay:YES];
        });
    });
}

@end
