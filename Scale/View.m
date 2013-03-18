//
//  View.m
//  Scale
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "View.h"
#import "Common.h"
#import "Fractal.h"

@implementation View

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.model = [Model mandelbrot];
        self.cache = [[Cache alloc] initWithView:self];
    }
    return self;
}

- (void)dealloc {
    self.model = nil;
    self.cache = nil;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)updateLabels {
    [self.inspectorPanel.mode selectSegmentWithTag:self.model.mode];
    self.inspectorPanel.zoomTextField.intValue = log(self.model.zoom) / log(2);
    self.inspectorPanel.detailTextField.intValue = log(self.model.max) / log(2);
    self.inspectorPanel.exponentTextField.intValue = self.model.power;
    self.inspectorPanel.zoomSlider.intValue = self.inspectorPanel.zoomTextField.intValue;
    self.inspectorPanel.detailSlider.intValue = self.inspectorPanel.detailTextField.intValue;
    self.inspectorPanel.exponentSlider.intValue = self.inspectorPanel.exponentTextField.intValue;
    self.inspectorPanel.zoomStepper.intValue = self.inspectorPanel.zoomTextField.intValue;
    self.inspectorPanel.detailStepper.intValue = self.inspectorPanel.detailTextField.intValue;
    self.inspectorPanel.exponentStepper.intValue = self.inspectorPanel.exponentTextField.intValue;
    self.inspectorPanel.centerX.doubleValue = self.model.x;
    self.inspectorPanel.centerY.doubleValue = self.model.y;
    if (self.model.mode == JULIA) {
        self.inspectorPanel.juliaX.doubleValue = self.model.jx;
        self.inspectorPanel.juliaY.doubleValue = self.model.jy;
        [self.inspectorPanel.juliaX setEnabled:YES];
        [self.inspectorPanel.juliaY setEnabled:YES];
    }
    else {
        self.inspectorPanel.juliaX.stringValue = @"";
        self.inspectorPanel.juliaY.stringValue = @"";
        [self.inspectorPanel.juliaX setEnabled:NO];
        [self.inspectorPanel.juliaY setEnabled:NO];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [self updateLabels];
    [self.cache setModel:self.model size:self.bounds.size];
    CGSize size = self.bounds.size;
    CGPoint a = [self.model screenToTile:CGPointMake(0, size.height) size:size];
    CGPoint b = [self.model screenToTile:CGPointMake(size.width, 0) size:size];
    [NSBezierPath fillRect:dirtyRect];
    NSDictionary *hints = [NSDictionary dictionaryWithObject:@(NSImageInterpolationNone) forKey:NSImageHintInterpolation];
    for (long j = a.y; j <= b.y; j++) {
        for (long i = a.x; i <= b.x; i++) {
            CGPoint point = [self.model tileToScreen:CGPointMake(i, j) size:size];
            NSRect dst = NSMakeRect(point.x, point.y, TILE_SIZE, TILE_SIZE);
            if (!CGRectIntersectsRect(dst, dirtyRect)) {
                continue;
            }
            NSImage *tile = [self.cache getTileWithZoom:self.model.zoom i:i j:j];
            if (tile) {
                [tile drawInRect:dst fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
                continue;
            }
            for (long m = 2; m <= 8; m *= 2) {
                long zoom = self.model.zoom / m;
                long p = floor((double)i / m);
                long q = floor((double)j / m);
                tile = [self.cache getTileWithZoom:zoom i:p j:q];
                if (tile) {
                    long size = TILE_SIZE / m;
                    long dx = i % m;
                    long dy = j % m;
                    dx = dx < 0 ? dx + m : dx;
                    dy = dy < 0 ? dy + m : dy;
                    NSRect src = NSMakeRect(dx * size, dy * size, size, size);
                    [tile drawInRect:dst fromRect:src operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:hints];
                    break;
                }
            }
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.bounds.size;
    if (event.clickCount % 2 == 0) {
        self.model = [self.model zoomInAtPoint:point size:size];
    }
    self.anchor = CGPointMake(self.model.x, self.model.y);
    self.dragPoint = point;
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGSize size = self.bounds.size;
    self.model = [self.model zoomOutAtPoint:point size:size];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    double dx = point.x - self.dragPoint.x;
    double dy = point.y - self.dragPoint.y;
    self.model = [self.model pan:CGPointMake(dx, dy) anchor:self.anchor];
    [self setNeedsDisplay:YES];
}

- (void)moveLeft:(id)sender {
    self.model = [self.model moveLeft];
    [self setNeedsDisplay:YES];
}

- (void)moveRight:(id)sender {
    self.model = [self.model moveRight];
    [self setNeedsDisplay:YES];
}

- (void)moveUp:(id)sender {
    self.model = [self.model moveUp];
    [self setNeedsDisplay:YES];
}

- (void)moveDown:(id)sender {
    self.model = [self.model moveDown];
    [self setNeedsDisplay:YES];
}

- (IBAction)onMandelbrot:(id)sender {
    self.model = [self.model withMandelbrot];
    [self setNeedsDisplay:YES];
}

- (IBAction)onJulia:(id)sender {
    self.model = [self.model withJulia];
    [self setNeedsDisplay:YES];
}

- (IBAction)onRandom:(id)sender {
    self.model = [self.model withRandom];
    [self setNeedsDisplay:YES];
}

- (IBAction)onResetZoom:(id)sender {
    self.model = [self.model resetZoom];
    [self setNeedsDisplay:YES];
}

- (IBAction)onZoomIn:(id)sender {
    self.model = [self.model zoomIn];
    [self setNeedsDisplay:YES];
}

- (IBAction)onZoomOut:(id)sender {
    self.model = [self.model zoomOut];
    [self setNeedsDisplay:YES];
}

- (IBAction)onMoreDetail:(id)sender {
    self.model = [self.model moreDetail];
    [self setNeedsDisplay:YES];
}

- (IBAction)onLessDetail:(id)sender {
    self.model = [self.model lessDetail];
    [self setNeedsDisplay:YES];
}

- (IBAction)onIncreaseExponent:(id)sender {
    self.model = [self.model morePower];
    self.juliaPanel.view.model = [self.juliaPanel.view.model withPower:self.model.power];
    [self setNeedsDisplay:YES];
}

- (IBAction)onDecreaseExponent:(id)sender {
    self.model = [self.model lessPower];
    self.juliaPanel.view.model = [self.juliaPanel.view.model withPower:self.model.power];
    [self setNeedsDisplay:YES];
}

- (IBAction)onColors:(id)sender {
    if (!self.gradientPanel.isVisible) {
        [self.gradientPanel makeKeyAndOrderFront:nil];
    }
    else {
        [self.gradientPanel orderOut:nil];
    }
}

- (IBAction)onInspector:(id)sender {
    if (!self.inspectorPanel.isVisible) {
        [self.inspectorPanel makeKeyAndOrderFront:nil];
    }
    else {
        [self.inspectorPanel orderOut:nil];
    }
}

- (IBAction)onJuliaSetPicker:(id)sender {
    if (!self.juliaPanel.isVisible) {
        [self.juliaPanel makeKeyAndOrderFront:nil];
    }
    else {
        [self.juliaPanel orderOut:nil];
    }
}

- (void)onGradient:(NSGradient *)gradient {
    self.model = [self.model withGradient:gradient];
    [self setNeedsDisplay:YES];
}

- (void)onGamma:(double)gamma {
    self.model = [self.model withGamma:gamma];
    [self setNeedsDisplay:YES];
}

- (void)onAntialiasing:(int)aa {
    self.model = [self.model withAntialiasing:aa];
    [self setNeedsDisplay:YES];
}

- (void)onInspector {
    self.model = [self.model withCenter:CGPointMake(self.inspectorPanel.centerX.doubleValue, self.inspectorPanel.centerY.doubleValue)];
    self.model = [self.model withJuliaSeed:CGPointMake(self.inspectorPanel.juliaX.doubleValue, self.inspectorPanel.juliaY.doubleValue)];
    self.model = [self.model withZoom:pow(2, self.inspectorPanel.zoomTextField.intValue)];
    self.model = [self.model withMax:pow(2, self.inspectorPanel.detailTextField.intValue)];
    self.model = [self.model withPower:self.inspectorPanel.exponentTextField.intValue];
    self.juliaPanel.view.model = [self.juliaPanel.view.model withPower:self.model.power];
    NSInteger mode = self.inspectorPanel.mode.selectedSegment + 1;
    if (mode != self.model.mode) {
        if (mode == MANDELBROT) {
            self.model = [self.model withMandelbrot];
        }
        else {
            self.model = [self.model withJulia];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)onJuliaSeed:(CGPoint)seed {
    self.model = [[self.model withJulia] withJuliaSeed:seed];
    [self setNeedsDisplay:YES];
}

- (void)doSave:(NSURL *)url {
    self.cancelSave = NO;
    double w = self.saveWidth.intValue;
    double h = self.saveHeight.intValue;
    double p = w / self.bounds.size.width;
    Model *model = [self.model copy];
    model = [model withZoom:model.zoom * p];
    model = [model withAntialiasing:(int)self.saveAntialiasing.selectedTag];
    CGSize size = CGSizeMake(w, h);
    CGPoint a = [model screenToTile:CGPointMake(0, h) size:size];
    CGPoint b = [model screenToTile:CGPointMake(w, 0) size:size];
    self.saveProgressIndicator.doubleValue = 0;
    self.saveProgressIndicator.minValue = 0;
    self.saveProgressIndicator.maxValue = (b.x - a.x + 1) * (b.y - a.y + 1);
    [NSApp beginSheet:self.saveProgressWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(saveProgressWindowDidEnd:returnCode:contextInfo:) contextInfo:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableDictionary *tiles = [NSMutableDictionary dictionary];
        dispatch_group_t group = dispatch_group_create();
        for (long j = a.y; j <= b.y; j++) {
            for (long i = a.x; i <= b.x; i++) {
                dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    if (self.cancelSave) {
                        return;
                    }
                    NSData *data = [Fractal computeTileDataWithMode:model.mode power:model.power max:model.max zoom:model.zoom i:i j:j aa:model.aa jx:model.jx jy:model.jy ref:nil];
                    NSImage *tile = [Fractal computeTileImageWithData:data palette:model.palette];
                    NSArray *key = [NSArray arrayWithObjects:@(i), @(j), nil];
                    @synchronized(tiles) {
                        [tiles setObject:tile forKey:key];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.saveProgressIndicator.doubleValue += 1;
                    });
                });
            }
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);
        if (!self.cancelSave) {
            NSImage *image = [[NSImage alloc] initWithSize:size];
            [image lockFocusFlipped:YES];
            for (long j = a.y; j <= b.y; j++) {
                for (long i = a.x; i <= b.x; i++) {
                    NSArray *key = [NSArray arrayWithObjects:@(i), @(j), nil];
                    NSImage *tile = [tiles objectForKey:key];
                    CGPoint point = [model tileToScreen:CGPointMake(i, j) size:size];
                    NSRect dst = NSMakeRect(point.x, point.y, TILE_SIZE, TILE_SIZE);
                    [tile drawInRect:dst fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
                }
            }
            [image unlockFocus];
            NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
            NSData *data = [bitmap representationUsingType:NSPNGFileType properties:nil];
            [data writeToURL:url atomically:NO];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp endSheet:self.saveProgressWindow];
        });
    });
}

- (void)saveProgressWindowDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [self.saveProgressWindow orderOut:self];
}

- (IBAction)onCancelSave:(id)sender {
    self.cancelSave = YES;
}

- (void)saveDocument:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    self.saveWidth.stringValue = [NSString stringWithFormat:@"%d", (int)self.bounds.size.width];
    self.saveHeight.stringValue = [NSString stringWithFormat:@"%d", (int)self.bounds.size.height];
    [self.saveAntialiasing selectItemWithTag:self.model.aa];
    panel.accessoryView = self.saveAccessoryView;
    panel.allowedFileTypes = [NSArray arrayWithObjects:@"png", nil];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode) {
        [panel makeFirstResponder:panel];
        if (returnCode == NSOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doSave:panel.URL];
            });
        }
    }];
}

- (IBAction)onSaveChange:(id)sender {
    int width = self.saveWidth.intValue;
    int height = self.saveHeight.intValue;
    if (width == 0) {
        width = self.bounds.size.width;
    }
    if (height == 0) {
        height = self.bounds.size.height;
    }
    double aspect = self.bounds.size.width / self.bounds.size.height;
    if (sender == self.saveWidth) {
        height = round(width / aspect);
    }
    if (sender == self.saveHeight) {
        width = round(height * aspect);
    }
    self.saveWidth.stringValue = [NSString stringWithFormat:@"%d", width];
    self.saveHeight.stringValue = [NSString stringWithFormat:@"%d", height];
}

@end
