//
//  Fractal.m
//  Scale
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "Fractal.h"
#import "Common.h"

volatile static BOOL cancelFlag = NO;

BOOL mandelbrot(int power, int max, int width, int height, double wx, double wy, double ww, double wh, unsigned short *data, const unsigned short *ref) {
    int index = 0;
    int p = power - 1;
    double dx = ww / width;
    double dy = wh / height;
    double y0 = wy + wh;
    for (int _y = 0; _y < height; _y++) {
        double x0 = wx;
        for (int _x = 0; _x < width; _x++) {
            if (ref && ref[index]) {
                data[index] = ref[index];
            }
            else {
                double x = 0;
                double y = 0;
                int iteration = 0;
                while (x * x + y * y < 4 && iteration < max) {
                    double a = x;
                    double b = y;
                    for (int i = 0; i < p; i++) {
                        double temp = a * x - b * y;
                        y = b * x + a * y;
                        x = temp;
                    }
                    x += x0;
                    y += y0;
                    iteration++;
                }
                data[index] = iteration == max ? 0 : iteration;
                if (cancelFlag) {
                    return NO;
                }
            }
            index++;
            x0 += dx;
        }
        y0 -= dy;
    }
    return YES;
}

BOOL julia(int power, int max, int width, int height, double wx, double wy, double ww, double wh, double jx, double jy, unsigned short *data, const unsigned short *ref) {
    int index = 0;
    int p = power - 1;
    double dx = ww / width;
    double dy = wh / height;
    double y0 = wy + wh;
    for (int _y = 0; _y < height; _y++) {
        double x0 = wx;
        for (int _x = 0; _x < width; _x++) {
            if (ref && ref[index]) {
                data[index] = ref[index];
            }
            else {
                double x = x0;
                double y = y0;
                int iteration = 1;
                while (x * x + y * y < 4 && iteration < max) {
                    double a = x;
                    double b = y;
                    for (int i = 0; i < p; i++) {
                        double temp = a * x - b * y;
                        y = b * x + a * y;
                        x = temp;
                    }
                    x += jx;
                    y += jy;
                    iteration++;
                }
                data[index] = iteration == max ? 0 : iteration;
                if (cancelFlag) {
                    return NO;
                }
            }
            index++;
            x0 += dx;
        }
        y0 -= dy;
    }
    return YES;
}

@implementation Fractal

+ (void)setCancelFlag:(BOOL)flag {
    @synchronized(self) {
        cancelFlag = flag;
    }
}

+ (NSData *)computePaletteWithGradient:(NSGradient *)gradient size:(int)size gamma:(double)gamma {
    NSImage *image = [[NSImage alloc] initWithSize:CGSizeMake(size, 1)];
    [image lockFocus];
    [gradient drawFromPoint:CGPointMake(0, 0) toPoint:CGPointMake(size, 0) options:0];
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, size, 1)];
    [image unlockFocus];
    unsigned int *data = (unsigned int *)bitmap.bitmapData;
    int length = sizeof(unsigned int) * size;
    unsigned int *palette = malloc(length);
    int hi = size - 1;
    for (int i = 0; i < size; i++) {
        double p = (double)i / hi;
        int x = hi * pow(p, gamma);
        palette[i] = data[x];
    }
    return [NSData dataWithBytesNoCopy:palette length:length];
}

+ (NSData *)computeTileDataWithMode:(int)mode power:(int)power max:(int)max zoom:(long)zoom i:(long)i j:(long)j aa:(int)aa jx:(double)jx jy:(double)jy ref:(NSData *)ref {
    int tile_size = TILE_SIZE * aa;
    int size = tile_size * tile_size;
    int length = sizeof(unsigned short) * size;
    double ww = (double)TILE_SIZE / zoom;
    double wx = i * ww;
    double wy = j * ww;
    unsigned short *data = malloc(length);
    BOOL result;
    if (mode == JULIA) {
        result = julia(power, max, tile_size, tile_size, wx, wy, ww, ww, jx, jy, data, ref.bytes);
    }
    else {
        result = mandelbrot(power, max, tile_size, tile_size, wx, wy, ww, ww, data, ref.bytes);
    }
    return result ? [NSData dataWithBytesNoCopy:data length:length] : nil;
}

+ (NSImage *)computeTileImageWithData:(NSData *)data palette:(NSData *)palette {
    const unsigned short *values = (const unsigned short *)data.bytes;
    const unsigned int *colors = (const unsigned int *)palette.bytes;
    int count = (int)data.length / sizeof(unsigned short);
    int hi = (int)palette.length / sizeof(unsigned int) - 1;
    unsigned int *pixels = malloc(sizeof(unsigned int) * count);
    for (int i = 0; i < count; i++) {
        int index = values[i];
        index = index ? index : hi;
        index = index <= hi ? index : hi;
        pixels[i] = colors[index];
    }
    int size = sqrt(count);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:size pixelsHigh:size bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:NSAlphaNonpremultipliedBitmapFormat bytesPerRow:size * 4 bitsPerPixel:32];
    memcpy(bitmap.bitmapData, pixels, size * size * 4);
    free(pixels);
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmap];
    if (size <= TILE_SIZE) {
        return image;
    }
    NSDictionary *hints = [NSDictionary dictionaryWithObject:@(NSImageInterpolationHigh) forKey:NSImageHintInterpolation];
    NSImage *tile = [[NSImage alloc] initWithSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
    [tile lockFocus];
    [image drawInRect:NSMakeRect(0, 0, TILE_SIZE, TILE_SIZE) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:NO hints:hints];
    [tile unlockFocus];
    return tile;
}

+ (CGPoint)randomMandelbrotWithPower:(int)power {
    int size = TILE_SIZE;
    int count = size * size;
    double wx = -2;
    double wy = -2;
    double ww = 4;
    double wh = 4;
    double x = 0;
    double y = 0;
    unsigned short *data = malloc(sizeof(unsigned short) * count);
    for (int n = 0; n < RANDOM_STEPS; n++) {
        mandelbrot(power, RANDOM_DETAIL, size, size, wx, wy, ww, wh, data, NULL);
        int hi = 0;
        for (int i = 0; i < count; i++) {
            hi = MAX(hi, data[i]);
        }
        int threshold = hi / 2;
        int index;
        while (1) {
            index = arc4random_uniform(count);
            if (data[index] >= threshold && data[index] < hi) {
                break;
            }
        }
        double i = index % size;
        double j = index / size;
        x = wx + ww * (i / size);
        y = wy + wh - wh * (j / size);
        ww /= 2;
        wh /= 2;
        wx = x - ww / 2;
        wy = y - wh / 2;
    }
    free(data);
    return CGPointMake(x, y);
}

+ (CGRect)randomJuliaWithPower:(int)power {
    CGPoint point = [Fractal randomMandelbrotWithPower:power];
    int size = TILE_SIZE;
    int count = size * size;
    double wx = -2;
    double wy = -2;
    double ww = 4;
    double wh = 4;
    double jx = point.x;
    double jy = point.y;
    double x = 0;
    double y = 0;
    unsigned short *data = malloc(sizeof(unsigned short) * count);
    for (int n = 0; n < RANDOM_STEPS; n++) {
        julia(power, RANDOM_DETAIL, size, size, wx, wy, ww, wh, jx, jy, data, NULL);
        int hi = 0;
        for (int i = 0; i < count; i++) {
            hi = MAX(hi, data[i]);
        }
        int threshold = hi / 2;
        int index;
        while (1) {
            index = arc4random_uniform(count);
            if (data[index] >= threshold && data[index] < hi) {
                break;
            }
        }
        double i = index % size;
        double j = index / size;
        x = wx + ww * (i / size);
        y = wy + wh - wh * (j / size);
        ww /= 2;
        wh /= 2;
        wx = x - ww / 2;
        wy = y - wh / 2;
    }
    free(data);
    return CGRectMake(x, y, jx, jy);
}

+ (NSData *)computeDataWithMode:(int)mode power:(int)power max:(int)max zoom:(long)zoom x:(double)x y:(double)y width:(int)width height:(int)height aa:(int)aa jx:(double)jx jy:(double)jy ref:(NSData *)ref {
    int aa_width = width * aa;
    int aa_height = height * aa;
    int size = aa_width * aa_height;
    int length = sizeof(unsigned short) * size;
    double ww = (double)width / zoom;
    double wh = (double)height / zoom;
    double wx = x - ww / 2;
    double wy = y - wh / 2;
    unsigned short *data = malloc(length);
    BOOL result;
    if (mode == JULIA) {
        result = julia(power, max, aa_width, aa_height, wx, wy, ww, wh, jx, jy, data, ref.bytes);
    }
    else {
        result = mandelbrot(power, max, aa_width, aa_height, wx, wy, ww, wh, data, ref.bytes);
    }
    return result ? [NSData dataWithBytesNoCopy:data length:length] : nil;
}

+ (NSImage *)computeImageWithData:(NSData *)data palette:(NSData *)palette width:(int)width height:(int)height aa:(int)aa {
    int aa_width = width * aa;
    int aa_height = height * aa;
    const unsigned short *values = (const unsigned short *)data.bytes;
    const unsigned int *colors = (const unsigned int *)palette.bytes;
    int count = (int)data.length / sizeof(unsigned short);
    int hi = (int)palette.length / sizeof(unsigned int) - 1;
    unsigned int *pixels = malloc(sizeof(unsigned int) * count);
    for (int i = 0; i < count; i++) {
        int index = values[i];
        index = index ? index : hi;
        index = index <= hi ? index : hi;
        pixels[i] = colors[index];
    }
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:aa_width pixelsHigh:aa_height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:NSAlphaNonpremultipliedBitmapFormat bytesPerRow:aa_width * 4 bitsPerPixel:32];
    memcpy(bitmap.bitmapData, pixels, aa_width * aa_height * 4);
    free(pixels);
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmap];
    if (aa == 1) {
        return image;
    }
    NSDictionary *hints = [NSDictionary dictionaryWithObject:@(NSImageInterpolationHigh) forKey:NSImageHintInterpolation];
    NSImage *tile = [[NSImage alloc] initWithSize:CGSizeMake(width, height)];
    [tile lockFocus];
    [image drawInRect:NSMakeRect(0, 0, width, height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:NO hints:hints];
    [tile unlockFocus];
    return tile;
}

@end
