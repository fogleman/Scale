//
//  LibraryPanel.h
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class View;

@interface LibraryPanel : NSPanel

@property (assign) IBOutlet View *fractalView;
@property (assign) IBOutlet NSCollectionView *collectionView;
@property (retain) NSMutableArray *items;

@end
