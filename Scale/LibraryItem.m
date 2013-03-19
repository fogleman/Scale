//
//  LibraryItem.m
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "LibraryItem.h"
#import "Fractal.h"

@implementation LibraryItem

+ (LibraryItem *)itemWithModel:(Model *)model {
    LibraryItem *item = [[LibraryItem alloc] init];
    item.model = model;
    CGSize size = CGSizeMake(120, 90);
    model = [model withZoom:model.zoom * size.width / 800.0];
    NSData *data = [Fractal computeDataWithMode:model.mode power:model.power max:model.max zoom:model.zoom x:model.x y:model.y width:size.width height:size.height aa:model.aa jx:model.jx jy:model.jy ref:nil];
    NSImage *image = [Fractal computeImageWithData:data palette:model.palette width:size.width height:size.height aa:model.aa];
    item.image = image;
    return item;
}

@end
