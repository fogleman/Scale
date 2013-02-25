//
//  Fractal.m
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "Fractal.h"
#import "Common.h"
#import "OpenCL/OpenCL.h"
#import "Fractal.cl.h"

void mandelbrot(int max, int width, int height, double wx, double wy, double ww, double wh, unsigned short *data) {
    int index = 0;
    double dx = ww / width;
    double dy = wh / height;
    double y0 = wy + wh;
    for (int _y = 0; _y < height; _y++) {
        double x0 = wx;
        for (int _x = 0; _x < width; _x++) {
            double x = 0;
            double y = 0;
            int iteration = 0;
            while (x * x + y * y < 4 && iteration < max) {
                double temp = x * x - y * y + x0;
                y = 2 * x * y + y0;
                x = temp;
                iteration++;
            }
            data[index] = iteration == max ? 0 : iteration;
            index++;
            x0 += dx;
        }
        y0 -= dy;
    }
}

void julia(int max, int width, int height, double wx, double wy, double ww, double wh, double jx, double jy, unsigned short *data) {
    int index = 0;
    double dx = ww / width;
    double dy = wh / height;
    double y0 = wy + wh;
    for (int _y = 0; _y < height; _y++) {
        double x0 = wx;
        for (int _x = 0; _x < width; _x++) {
            double x = x0;
            double y = y0;
            int iteration = 1;
            while (x * x + y * y < 4 && iteration < max) {
                double temp = x * x - y * y + jx;
                y = 2 * x * y + jy;
                x = temp;
                iteration++;
            }
            data[index] = iteration == max ? 0 : iteration;
            index++;
            x0 += dx;
        }
        y0 -= dy;
    }
}

@implementation Fractal

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

+ (NSData *)computeTileDataWithMode:(int)mode max:(int)max zoom:(long)zoom i:(long)i j:(long)j aa:(int)aa jx:(double)jx jy:(double)jy {
    int tile_size = TILE_SIZE * aa;
    int size = tile_size * tile_size;
    int length = sizeof(unsigned short) * size;
    double ww = (double)TILE_SIZE / zoom;
    double wx = i * ww;
    double wy = j * ww;
    unsigned short *data = malloc(length);
    if (mode == JULIA) {
        julia(max, tile_size, tile_size, wx, wy, ww, ww, jx, jy, data);
    }
    else {
        mandelbrot(max, tile_size, tile_size, wx, wy, ww, ww, data);
    }
    return [NSData dataWithBytesNoCopy:data length:length];
}

+ (NSData *)clComputeTileDataWithMode:(int)mode max:(int)max zoom:(long)zoom i:(long)i j:(long)j aa:(int)aa jx:(float)jx jy:(float)jy {
    int tile_size = TILE_SIZE * aa;
    int size = tile_size * tile_size;
    int length = sizeof(cl_ushort) * size;
    float ww = (float)TILE_SIZE / zoom;
    float wx = i * ww;
    float wy = j * ww;
    void *data = malloc(length);
    void *cl_data = gcl_malloc(length, NULL, CL_MEM_WRITE_ONLY);
    dispatch_queue_t queue = gcl_create_dispatch_queue(CL_DEVICE_TYPE_GPU, NULL);
    if (!queue) {
        queue = gcl_create_dispatch_queue(CL_DEVICE_TYPE_CPU, NULL);
    }
    dispatch_sync(queue, ^{
        cl_ndrange range = {1, {0, 0, 0}, {size, 0, 0}, {0, 0, 0}};
        if (mode == JULIA) {
            julia_kernel(&range, max, tile_size, tile_size, wx, wy, ww, ww, jx, jy, cl_data);
        }
        else {
            mandelbrot_kernel(&range, max, tile_size, tile_size, wx, wy, ww, ww, cl_data);
        }
        gcl_memcpy(data, cl_data, length);
    });
    dispatch_release(queue);
    gcl_free(cl_data);
    return [NSData dataWithBytesNoCopy:data length:length];
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

@end
