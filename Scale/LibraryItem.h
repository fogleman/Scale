//
//  LibraryItem.h
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface LibraryItem : NSObject

@property (retain) Model *model;
@property (retain) NSImage *image;

+ (LibraryItem *)itemWithModel:(Model *)model;

@end
