//
//  DREffectDelegate.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DREffectDelegate <NSObject>

- (void)layerDidUpdateContent:(id)layer;
- (void)layerDidUpdateImageEffect:(id)layer imageEffect:(DRImageEffect*)imageEffect;
- (void)layerDidUpdateOverlayMask:(id)layer overlayMask:(UIBezierPath*)overlayMask;
- (void)layerDidUpdateMaskPosition:(id)layer maskPosition:(CGPoint)maskPosition;

- (void)layerDidChangeParallaxEffect:(id)layer parallaxEffect:(BOOL)parallaxEffect;

@end
