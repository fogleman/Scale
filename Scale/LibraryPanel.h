//
//  LibraryPanel.h
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LibraryPanel : NSPanel

@property (assign) IBOutlet NSArrayController *arrayController;
@property (retain) NSMutableArray *items;
@property (retain) NSIndexSet *selectedItems;

@end
