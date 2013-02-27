//
//  Model.h
//  Tart
//
//  Created by Michael Fogleman on 2/24/13.
//  Copyright (c) 2013 Michael Fogleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject <NSCopying>

@property (assign, readonly, nonatomic) int mode;
@property (assign, readonly, nonatomic) int max;
@property (assign, readonly, nonatomic) long zoom;
@property (assign, readonly, nonatomic) double x;
@property (assign, readonly, nonatomic) double y;
@property (assign, readonly, nonatomic) int aa;
@property (assign, readonly, nonatomic) double jx;
@property (assign, readonly, nonatomic) double jy;
@property (assign, readonly, nonatomic) double gamma;
@property (retain, readonly, nonatomic) NSGradient *gradient;
@property (retain, readonly, nonatomic) NSData *palette;

+ (Model *)mandelbrot;
+ (Model *)julia;
+ (Model *)random;

- (BOOL)dataCompatible:(Model *)model;
- (BOOL)imageCompatible:(Model *)model;

- (CGPoint)tileToScreen:(CGPoint)point size:(CGSize)size center:(CGPoint)center zoom:(long)zoom;
- (CGPoint)tileToScreen:(CGPoint)point size:(CGSize)size;
- (CGPoint)screenToTile:(CGPoint)point size:(CGSize)size center:(CGPoint)center zoom:(long)zoom;
- (CGPoint)screenToTile:(CGPoint)point size:(CGSize)size;
- (CGPoint)pointToScreen:(CGPoint)point size:(CGSize)size;
- (CGPoint)screenToPoint:(CGPoint)point size:(CGSize)size;

- (Model *)withCenter:(CGPoint)point;
- (Model *)withJulia:(CGPoint)point;
- (Model *)withMax:(int)max;
- (Model *)withZoom:(long)zoom;
- (Model *)withGradient:(NSGradient *)gradient;
- (Model *)withGamma:(double)gamma;
- (Model *)withAntialiasing:(int)aa;
- (Model *)moreDetail;
- (Model *)lessDetail;
- (Model *)zoomIn;
- (Model *)zoomInAtPoint:(CGPoint)point size:(CGSize)size;
- (Model *)zoomOut;
- (Model *)zoomOutAtPoint:(CGPoint)point size:(CGSize)size;
- (Model *)pan:(CGPoint)offset anchor:(CGPoint)anchor;
- (Model *)moveLeft;
- (Model *)moveRight;
- (Model *)moveUp;
- (Model *)moveDown;

@end
