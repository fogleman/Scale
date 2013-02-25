//
//  Fractal.h
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fractal : NSObject

+ (NSData *)computePaletteWithGradient:(NSGradient *)gradient size:(int)size gamma:(double)gamma;

+ (NSData *)computeTileDataWithMode:(int)mode max:(int)max zoom:(long)zoom i:(long)i j:(long)j aa:(int)aa jx:(double)jx jy:(double)jy;

+ (NSData *)clComputeTileDataWithMode:(int)mode max:(int)max zoom:(long)zoom i:(long)i j:(long)j aa:(int)aa jx:(float)jx jy:(float)jy;

+ (NSImage *)computeTileImageWithData:(NSData *)data palette:(NSData *)palette;

@end
