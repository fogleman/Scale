//
//  InspectorPanel.m
//  Fractals
//
//  Created by Michael Fogleman on 2/21/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import "InspectorPanel.h"
#import "View.h"

@implementation InspectorPanel

- (IBAction)onChange:(id)sender {
    [self.fractalView onInspector];
}

- (IBAction)onZoom:(id)sender {
    self.zoomTextField.intValue = [sender intValue];
    [self.fractalView onInspector];
}

- (IBAction)onDetail:(id)sender {
    self.detailTextField.intValue = [sender intValue];
    [self.fractalView onInspector];
}

- (IBAction)onExponent:(id)sender {
    self.exponentTextField.intValue = [sender intValue];
    [self.fractalView onInspector];
}

@end
