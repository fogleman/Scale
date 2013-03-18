//
//  LibraryPanel.m
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "LibraryPanel.h"
#import "LibraryItem.h"

@implementation LibraryPanel

@synthesize selectedItems = _selectedItems;

- (id)init {
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}

- (void)awakeFromNib {
    for (int i = 0; i < 10; i++) {
        [self.arrayController addObject:[LibraryItem itemWithImage:[NSImage imageNamed:@"mandelbrot.png"]]];
    }
}

- (NSIndexSet *)selectedItems {
    return _selectedItems;
}

- (void)setSelectedItems:(NSIndexSet *)selectedItems {
    _selectedItems = selectedItems;
}

@end
