//
//  LibraryItem.h
//  Scale
//
//  Created by Michael Fogleman on 3/17/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryItem : NSObject

@property (retain) NSImage *image;

+ (LibraryItem *)itemWithImage:(NSImage *)image;

@end
