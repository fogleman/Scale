//
//  Fractal.h
//  Scale
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fractal : NSObject

+ (void)setCancelFlag:(BOOL)flag;

+ (NSData *)computePaletteWithGradient:(NSGradient *)gradient size:(int)size gamma:(double)gamma;

+ (NSData *)computeTileDataWithMode:(int)mode power:(int)power max:(int)max zoom:(long)zoom i:(long)i j:(long)j aa:(int)aa jx:(double)jx jy:(double)jy ref:(NSData *)ref;

+ (NSImage *)computeTileImageWithData:(NSData *)data palette:(NSData *)palette;

+ (CGPoint)randomMandelbrotWithPower:(int)power;

+ (CGRect)randomJuliaWithPower:(int)power;

+ (NSData *)computeDataWithMode:(int)mode power:(int)power max:(int)max zoom:(long)zoom x:(double)x y:(double)y width:(int)width height:(int)height aa:(int)aa jx:(double)jx jy:(double)jy ref:(NSData *)ref;

+ (NSImage *)computeImageWithData:(NSData *)data palette:(NSData *)palette width:(int)width height:(int)height aa:(int)aa;

@end
