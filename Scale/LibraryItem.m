//
//  LibraryItem.m
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "LibraryItem.h"

@implementation LibraryItem

+ (LibraryItem *)itemWithModel:(Model *)model image:(NSImage *)image {
    LibraryItem *item = [[LibraryItem alloc] init];
    item.model = model;
    item.image = image;
    return item;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.model = [coder decodeObjectForKey:@"model"];
        self.image = [coder decodeObjectForKey:@"image"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.model forKey:@"model"];
    [coder encodeObject:self.image forKey:@"image"];
}

@end
