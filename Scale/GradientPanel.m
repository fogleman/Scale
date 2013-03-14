//
//  GradientPanel.m
//  Fractals
//
//  Created by Michael Fogleman on 2/20/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "GradientPanel.h"
#import "Common.h"
#import "Util.h"
#import "View.h"

#define N_COLORS 6

@implementation GradientPanel

- (void)awakeFromNib {
    self.checkBoxes = [NSMutableArray array];
    self.colorWells = [NSMutableArray array];
    self.sliders = [NSMutableArray array];
    for (int i = 0; i < N_COLORS; i++) {
        [self.checkBoxes addObject:[NSNull null]];
        [self.colorWells addObject:[NSNull null]];
        [self.sliders addObject:[NSNull null]];
    }
    NSView *view = self.contentView;
    for (NSObject *child in view.subviews) {
        if (![child isKindOfClass:[NSControl class]]) {
            continue;
        }
        NSControl *control = (NSControl *)child;
        if (!control.tag) {
            continue;
        }
        control.target = self;
        control.action = @selector(onChange:);
        NSInteger index = control.tag - 1;
        if ([control isKindOfClass:[NSButton class]]) {
            [self.checkBoxes insertObject:child atIndex:index];
        }
        if ([control isKindOfClass:[NSColorWell class]]) {
            [self.colorWells insertObject:child atIndex:index];
        }
        if ([control isKindOfClass:[NSSlider class]]) {
            [self.sliders insertObject:child atIndex:index];
        }
    }
    [self loadPresets];
    [self onPreset:nil];
}

- (void)dealloc {
    self.checkBoxes = nil;
    self.colorWells = nil;
    self.sliders = nil;
    self.names = nil;
    self.gradients = nil;
}

- (NSGradient *)createGradient {
    NSMutableArray *colors = [NSMutableArray array];
    CGFloat *locations = malloc(sizeof(CGFloat) * N_COLORS);
    for (int i = 0; i < N_COLORS; i++) {
        NSButton *checkBox = [self.checkBoxes objectAtIndex:i];
        NSColorWell *colorWell = [self.colorWells objectAtIndex:i];
        NSSlider *slider = [self.sliders objectAtIndex:i];
        if (checkBox.state == NSOffState) {
            continue;
        }
        locations[colors.count] = slider.doubleValue;
        [colors addObject:colorWell.color];
    }
    NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace deviceRGBColorSpace]];
    free(locations);
    return gradient;
}

- (void)setGradient:(NSGradient *)gradient {
    for (int i = 0; i < N_COLORS; i++) {
        NSButton *checkBox = [self.checkBoxes objectAtIndex:i];
        NSColorWell *colorWell = [self.colorWells objectAtIndex:i];
        NSSlider *slider = [self.sliders objectAtIndex:i];
        checkBox.state = NSOffState;
        colorWell.color = [NSColor blueColor];
        slider.doubleValue = 0.5;
    }
    for (int i = 0; i < gradient.numberOfColorStops; i++) {
        NSButton *checkBox = [self.checkBoxes objectAtIndex:i];
        NSColorWell *colorWell = [self.colorWells objectAtIndex:i];
        NSSlider *slider = [self.sliders objectAtIndex:i];
        NSColor *color;
        CGFloat location;
        [gradient getColor:&color location:&location atIndex:i];
        checkBox.state = NSOnState;
        colorWell.color = color;
        slider.doubleValue = location;
    }
    [self onChange:nil];
}

- (void)onChange:(id)sender {
    self.gradientView.gradient = [self createGradient];
    [self.gradientView setNeedsDisplay:YES];
    [self.fractalView onGradient:self.gradientView.gradient];
}

- (IBAction)onGamma:(id)sender {
    NSSlider *slider = (NSSlider *)sender;
    [self.fractalView onGamma:slider.doubleValue];
}

- (IBAction)onAntialiasing:(id)sender {
    NSPopUpButton *button = (NSPopUpButton *)sender;
    [self.fractalView onAntialiasing:(int)button.selectedTag];
}

- (void)loadPresets {
    NSString *name;
    NSArray *colors;
    NSGradient *gradient;
    
    self.names = [NSMutableArray array];
    self.gradients = [NSMutableArray array];
    
    name = @"Preset 1";
    colors = [NSArray arrayWithObjects:[Common color:0x580022], [Common color:0xAA2C30], [Common color:0xFFBE8D], [Common color:0x487B7F], [Common color:0x011D24], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 2";
    colors = [NSArray arrayWithObjects:[Common color:0xF6F9F4], [Common color:0xBCB293], [Common color:0x776B5C], [Common color:0x4C393D], [Common color:0x1C1A24], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 3";
    colors = [NSArray arrayWithObjects:[Common color:0x736C48], [Common color:0xF2E3B3], [Common color:0xF2A950], [Common color:0xD98032], [Common color:0xD95D30], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 4";
    colors = [NSArray arrayWithObjects:[Common color:0xFF2C38], [Common color:0xFFFFED], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 5";
    colors = [NSArray arrayWithObjects:[Common color:0x8BA5C4], [Common color:0x25303D], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 6";
    colors = [NSArray arrayWithObjects:[Common color:0xEBD096], [Common color:0xD1B882], [Common color:0x5D8A66], [Common color:0x1A6566], [Common color:0x21445B], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 7";
    colors = [NSArray arrayWithObjects:[Common color:0xBF9F63], [Common color:0x261F1D], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 8";
    colors = [NSArray arrayWithObjects:[Common color:0xD9961A], [Common color:0x261B11], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 9";
    colors = [NSArray arrayWithObjects:[Common color:0x21487F], [Common color:0x001C3D], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 10";
    colors = [NSArray arrayWithObjects:[Common color:0xF2F2F2], [Common color:0x038C3E], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 11";
    colors = [NSArray arrayWithObjects:[Common color:0xF2B66D], [Common color:0x365902], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 12";
    colors = [NSArray arrayWithObjects:[Common color:0xE81C0C], [Common color:0xE8C57A], [Common color:0x166870], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 13";
    colors = [NSArray arrayWithObjects:[Common color:0x2B383B], [Common color:0xD05F46], [Common color:0xFDE459], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 14";
    colors = [NSArray arrayWithObjects:[Common color:0x8C2703], [Common color:0xBF6211], [Common color:0xF5D799], [Common color:0x7BA69A], [Common color:0x59532F], [Common color:0x000000], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 15";
    colors = [NSArray arrayWithObjects:[Common color:0xFF7F66], [Common color:0xFFF6E5], [Common color:0x7ECEFD], [Common color:0x2185C5], [Common color:0x3E454C], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    name = @"Preset 16";
    colors = [NSArray arrayWithObjects:[Common color:0xBAC45E], [Common color:0xADA344], [Common color:0x734A22], [Common color:0x4C2D22], [Common color:0x261B1D], nil];
    gradient = [[NSGradient alloc] initWithColors:colors];
    [self.names addObject:name];
    [self.gradients addObject:gradient];
    
    for (NSString *name in self.names) {
        [self.presetsButton addItemWithTitle:name];
    }
    [self.presetsButton selectItemAtIndex:0];
}

- (IBAction)onPreset:(id)sender {
    NSInteger index = self.presetsButton.indexOfSelectedItem;
    NSGradient *gradient = [self.gradients objectAtIndex:index];
    [self setGradient:gradient];
}

@end
