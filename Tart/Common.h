//
//  Common.h
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TILE_SIZE 128

#define MANDELBROT 1
#define JULIA 2

#define INITIAL_DETAIL 512
#define MIN_DETAIL 16
#define MAX_DETAIL 65536

#define INITIAL_ZOOM 256
#define MIN_ZOOM 64
#define MAX_ZOOM 137438953472

#define INITIAL_AA 2
#define INITIAL_GAMMA 0.5

#define PAN_FACTOR 64

@interface Common : NSObject

+ (void)shuffleArray:(NSMutableArray *)array;
+ (NSColor *)color:(unsigned int)value;

@end
