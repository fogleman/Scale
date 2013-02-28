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
#define LOOKUP(x, i) (((NSNumber *)[(x) objectForKey:(i)]).integerValue)

@implementation Cache

- (id)initWithView:(View *)view {
    self = [super init];
    if (self) {
        self.model = nil;
        self.view = view;
        self.seen = [NSMutableSet set];
        self.dataCache = [NSMutableDictionary dictionary];
        self.maxCache = [NSMutableDictionary dictionary];
        self.imageCache = [NSMutableDictionary dictionary];
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            self.queue = dispatch_queue_create("com.michaelfogleman.Tart.Cache", DISPATCH_QUEUE_CONCURRENT);
        });
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
    dispatch_release(self.queue);
}

- (NSImage *)getTileWithZoom:(long)zoom i:(long)i j:(long)j {
    NSArray *key = @[@(i), @(j), @(zoom)];
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
        [Fractal setCancelFlag:YES];
        dispatch_barrier_async(self.queue, ^{
            [Fractal setCancelFlag:NO];
        });
    }
    if (![model imageCompatible:self.model]) {
        [self.seen removeAllObjects];
    }
    if (model.max > self.model.max) {
        [self.seen removeAllObjects];
        [Fractal setCancelFlag:YES];
        dispatch_barrier_async(self.queue, ^{
            [Fractal setCancelFlag:NO];
        });
    }
    self.model = model;
    self.size = size;
    self.a = [model screenToTile:CGPointMake(0, size.height) size:size];
    self.b = [model screenToTile:CGPointMake(size.width, 0) size:size];
    [self purgeCaches];
    [self ensureKeysWithZoom:self.model.zoom a:self.a b:self.b];
}

- (void)ensureKeysWithZoom:(long)zoom a:(CGPoint)a b:(CGPoint)b {
    NSMutableArray *keys = [NSMutableArray array];
    for (long j = a.y; j <= b.y; j++) {
        for (long i = a.x; i <= b.x; i++) {
            NSArray *key = @[@(i), @(j), @(zoom)];
            [keys addObject:key];
        }
    }
    [Common shuffleArray:keys];
    for (NSArray *key in keys) {
        [self ensureKey:key];
    }
}

- (BOOL)isKeyVisible:(NSArray *)key {
    long i = UNPACK(key, 0);
    long j = UNPACK(key, 1);
    long zoom = UNPACK(key, 2);
    if (zoom != self.model.zoom) {
        return NO;
    }
    if (i < self.a.x || i > self.b.x) {
        return NO;
    }
    if (j < self.a.y || j > self.b.y) {
        return NO;
    }
    return YES;
}

- (BOOL)isKeyStale:(NSArray *)key {
    // TODO: synchronize?
    // TODO: check model compatibility
    return ![self isKeyVisible:key];
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
    int cachedMax = (int)LOOKUP(self.maxCache, key);
    if (cachedData && cachedMax >= model.max) {
        NSImage *image = [Fractal computeTileImageWithData:cachedData palette:model.palette];
        [self.imageCache setObject:image forKey:key];
        return;
    }
    dispatch_async(self.queue, ^{
        if ([self isKeyStale:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.seen removeObject:key];
                [self.view setNeedsDisplay:YES];
            });
            return;
        }
        NSData *data = [Fractal computeTileDataWithMode:model.mode max:model.max zoom:zoom i:i j:j aa:model.aa jx:model.jx jy:model.jy ref:cachedData];
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.seen removeObject:key];
                [self.view setNeedsDisplay:YES];
            });
            return;
        }
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

- (void)purgeCache:(NSMutableDictionary *)cache {
    NSMutableArray *keys = [NSMutableArray array];
    for (NSArray *key in cache) {
        if (![self isKeyVisible:key]) {
            [keys addObject:key];
        }
    }
    [cache removeObjectsForKeys:keys];
    [self.seen minusSet:[NSSet setWithArray:keys]];
}

- (void)purgeCaches {
    if (self.dataCache.count > MAX_TILES) {
        [self purgeCache:self.dataCache];
        [self purgeCache:self.maxCache];
    }
    if (self.imageCache.count > MAX_TILES) {
        [self purgeCache:self.imageCache];
    }
}

@end
