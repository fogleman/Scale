//
//  StaticView.m
//  Scale
//
//  Created by Michael Fogleman on 3/1/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "StaticView.h"
#import "Fractal.h"

@implementation StaticView

@synthesize model = _model;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.model = nil;
    }
    return self;
}

- (void)dealloc {
    self.model = nil;
}

- (BOOL)isFlipped {
    return YES;
}

- (Model *)model {
    return _model;
}

- (void)setModel:(Model *)model {
    _model = model;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    Model *model = self.model;
    CGSize size = self.bounds.size;
    NSData *data = [Fractal computeDataWithMode:model.mode power:model.power max:model.max zoom:model.zoom x:model.x y:model.y width:size.width height:size.height aa:model.aa jx:model.jx jy:model.jy ref:nil];
    NSImage *image = [Fractal computeImageWithData:data palette:model.palette width:size.width height:size.height aa:model.aa];
    [image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
}

@end
