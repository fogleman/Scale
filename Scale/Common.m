//
//  Common.m
//  Scale
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (void)shuffleArray:(NSMutableArray *)array {
    for (long i = array.count - 1; i > 0; i--) {
        int j = arc4random_uniform((int)i + 1);
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

+ (NSColor *)color:(unsigned int)value {
    double r = ((value >> 16) & 0xff) / 255.0;
    double g = ((value >> 8) & 0xff) / 255.0;
    double b = ((value >> 0) & 0xff) / 255.0;
    double a = 1.0;
    return [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
}

@end
