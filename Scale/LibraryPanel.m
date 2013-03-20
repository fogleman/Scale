//
//  LibraryPanel.m
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "LibraryPanel.h"
#import "LibraryItem.h"
#import "Fractal.h"
#import "Model.h"
#import "View.h"

@implementation LibraryPanel

- (void)awakeFromNib {
    NSArray *items = [self load];
    if (items.count == 0) {
        items = [self loadDefaults];
    }
    self.items = [NSMutableArray arrayWithArray:items];
    [self.collectionView addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
    [self onItemsChanged];
}

- (NSArray *)loadDefaults {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"library" withExtension:@"dat"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        @try {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            return [NSArray array];
        }
    }
    else {
        return [NSArray array];
    }
}

- (NSArray *)load {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"library"];
    if (data) {
        @try {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            return [NSArray array];
        }
    }
    else {
        return [NSArray array];
    }
}

- (void)save {
    NSArray *items = [NSArray arrayWithArray:self.items];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"library"];
}

- (void)onItemsChanged {
    NSArray *items = [NSArray arrayWithArray:self.items];
    [self.collectionView setContent:items];
    [self save];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.selectionIndexes = [change objectForKey:NSKeyValueChangeNewKey];
    [self.removeButton setEnabled:self.selectionIndexes.count];
    if (self.selectionIndexes.count == 1) {
        LibraryItem *item = [self.items objectAtIndex:self.selectionIndexes.firstIndex];
        [self.fractalView onLibraryModel:item.model];
    }
}

- (IBAction)onSave:(id)sender {
    CGSize size = CGSizeMake(120, 90);
    Model *model = self.fractalView.model;
    model = [model withZoom:model.zoom * size.width / 800.0];
    NSData *data = [Fractal computeDataWithMode:model.mode power:model.power max:model.max zoom:model.zoom x:model.x y:model.y width:size.width height:size.height aa:model.aa jx:model.jx jy:model.jy ref:nil];
    NSImage *image = [Fractal computeImageWithData:data palette:model.palette width:size.width height:size.height aa:model.aa];
    [self.items addObject:[LibraryItem itemWithModel:self.fractalView.model image:image]];
    [self onItemsChanged];
}

- (IBAction)onRemove:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Remove"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Remove the selected fractals from the library?"];
    [alert setInformativeText:@"This action cannot be undone."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self modalDelegate:self didEndSelector:@selector(removeAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)removeAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [self.items removeObjectsAtIndexes:self.selectionIndexes];
        [self onItemsChanged];
    }
}

- (IBAction)onRestore:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Restore Defaults"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Restore the library to its original defaults?"];
    [alert setInformativeText:@"All user-created fractals will be removed."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self modalDelegate:self didEndSelector:@selector(restoreAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)restoreAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        self.items = [NSMutableArray arrayWithArray:[self loadDefaults]];
        [self onItemsChanged];
    }
}

@end
