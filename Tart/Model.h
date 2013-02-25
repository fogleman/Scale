//
//  Model.h
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (assign) int mode;
@property (assign) int max;
@property (assign) long zoom;
@property (assign) double x;
@property (assign) double y;
@property (assign) int aa;
@property (assign) double jx;
@property (assign) double jy;
@property (assign) double gamma;

- (void)mandelbrot;
- (void)julia;

- (CGPoint)tileToScreen:(CGPoint)point center:(CGPoint)center size:(CGSize)size zoom:(long)zoom;
- (CGPoint)tileToScreen:(CGPoint)point size:(CGSize)size;
- (CGPoint)screenToTile:(CGPoint)point center:(CGPoint)center size:(CGSize)size zoom:(long)zoom;
- (CGPoint)screenToTile:(CGPoint)point size:(CGSize)size;
- (CGPoint)pointToScreen:(CGPoint)point size:(CGSize)size;
- (CGPoint)screenToPoint:(CGPoint)point size:(CGSize)size;

- (void)zoomIn;
- (void)zoomInAtPoint:(CGPoint)point size:(CGSize)size;
- (void)zoomOut;
- (void)zoomOutAtPoint:(CGPoint)point size:(CGSize)size;
- (void)pan:(CGPoint)offset anchor:(CGPoint)anchor;
- (void)moveLeft;
- (void)moveRight;
- (void)moveUp;
- (void)moveDown;

@end
