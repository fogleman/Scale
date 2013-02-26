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
@property (retain) NSMutableOrderedSet *seen;
@property (retain) NSMutableDictionary *dataCache;
@property (retain) NSMutableDictionary *maxLookup;
@property (retain) NSMutableDictionary *imageCache;
@property (assign) CGSize size;
@property (assign) CGPoint a;
@property (assign) CGPoint b;

- (id)initWithView:(View *)view;
- (void)setModel:(Model *)model size:(CGSize)size;
- (NSImage *)getTileWithZoom:(long)zoom i:(long)i j:(long)j;

@end
