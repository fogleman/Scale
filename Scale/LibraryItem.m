//
//  LibraryItem.m
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "LibraryItem.h"

@implementation LibraryItem

+ (LibraryItem *)itemWithImage:(NSImage *)image {
    LibraryItem *item = [[LibraryItem alloc] init];
    item.image = image;
    return item;
}

@end
