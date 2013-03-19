//
//  LibraryPanel.m
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "LibraryPanel.h"
#import "LibraryItem.h"
#import "Model.h"
#import "View.h"

@implementation LibraryPanel

- (void)awakeFromNib {
    self.items = [NSMutableArray array];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]];
    for (int i = 0; i < 32; i++) {
        Model *model = [[[Model mandelbrot] withJulia] withGradient:gradient];
        [self.items addObject:[LibraryItem itemWithModel:model]];
    }
    [self.collectionView setContent:[NSArray arrayWithArray:self.items]];
    [self.collectionView addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSIndexSet *selectedItems = [change objectForKey:NSKeyValueChangeNewKey];
    if (selectedItems.count == 1) {
        LibraryItem *item = [self.items objectAtIndex:selectedItems.firstIndex];
        [self.fractalView onLibraryModel:item.model];
    }
}

- (IBAction)onSave:(id)sender {
}

- (IBAction)onRemove:(id)sender {
}

@end
