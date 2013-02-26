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

@implementation Cache

- (id)initWithView:(View *)view {
    self = [super init];
    if (self) {
        self.model = nil;
        self.view = view;
        self.seen = [NSMutableOrderedSet orderedSet];
        self.dataCache = [NSMutableDictionary dictionary];
        self.maxLookup = [NSMutableDictionary dictionary];
        self.imageCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.model = nil;
    self.seen = nil;
    self.dataCache = nil;
    self.maxLookup = nil;
    self.imageCache = nil;
}

- (void)setModel:(Model *)model size:(CGSize)size {
    if (model == self.model && size.width == self.size.width && size.height == self.size.height) {
        return;
    }
    self.model = model;
    self.size = size;
    self.a = [model screenToTile:CGPointMake(0, size.height) size:size];
    self.b = [model screenToTile:CGPointMake(size.width, 0) size:size];
    [self ensureAll];
}

- (NSImage *)getTileWithZoom:(long)zoom i:(long)i j:(long)j {
    NSArray *key = [NSArray arrayWithObjects:@(i), @(j), @(zoom), nil];
    return [self.imageCache objectForKey:key];
}

- (void)ensureAll {
    CGPoint a = self.a;
    CGPoint b = self.b;
    NSMutableArray *keys = [NSMutableArray array];
    for (long j = a.y; j <= b.y; j++) {
        for (long i = a.x; i <= b.x; i++) {
            NSArray *key = [NSArray arrayWithObjects:@(i), @(j), @(self.model.zoom), nil];
            [keys addObject:key];
        }
    }
    [Common shuffleArray:keys];
    for (NSArray *key in keys) {
        [self ensureKey:key];
    }
}

- (void)ensureKey:(NSArray *)key {
    if ([self.seen containsObject:key]) {
        return;
    }
    [self.seen addObject:key];
    Model *model = self.model;
    long i = ((NSNumber *)[key objectAtIndex:0]).integerValue;
    long j = ((NSNumber *)[key objectAtIndex:1]).integerValue;
    long zoom = ((NSNumber *)[key objectAtIndex:2]).integerValue;
    NSData *cachedData = [self.dataCache objectForKey:key];
    int cachedMax = ((NSNumber *)[self.maxLookup objectForKey:key]).intValue;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL abort = NO;
        if (zoom != self.model.zoom) {
            abort = YES;
        }
        if (i < self.a.x || i > self.b.x) {
            abort = YES;
        }
        if (j < self.a.y || j > self.b.y) {
            abort = YES;
        }
        if (abort) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.seen removeObject:key];
                [self.view setNeedsDisplay:YES];
            });
            return;
        }
        NSData *data;
        int max;
        if (cachedData && cachedMax >= model.max) {
            data = cachedData;
            max = cachedMax;
        }
        else {
            data = [Fractal computeTileDataWithMode:model.mode max:model.max zoom:zoom i:i j:j aa:model.aa jx:model.jx jy:model.jy];
            max = model.max;
        }
        NSImage *image = [Fractal computeTileImageWithData:data palette:model.palette];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataCache setObject:data forKey:key];
            [self.maxLookup setObject:@(max) forKey:key];
            [self.imageCache setObject:image forKey:key];
            [self.view setNeedsDisplay:YES];
        });
    });
}

@end
