//
//  Cache.h
//  Tart
//
//  Created by Michael Fogleman on 2/25/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@class View;

@interface Cache : NSObject

@property (retain) Model *model;
@property (retain) View *view;
@property (retain) NSMutableSet *seen;
@property (retain) NSMutableDictionary *dataCache;
@property (retain) NSMutableDictionary *maxCache;
@property (retain) NSMutableDictionary *imageCache;
@property (assign) CGSize size;
@property (assign) CGPoint a;
@property (assign) CGPoint b;
@property (assign) dispatch_queue_t queue;

- (id)initWithView:(View *)view;
- (NSImage *)getTileWithZoom:(long)zoom i:(long)i j:(long)j;
- (void)setModel:(Model *)model size:(CGSize)size;

@end
