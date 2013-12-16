//
//  DRLayerViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRLayerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DRLayerViewController ()

@end

@implementation DRLayerViewController

- (void)setParallaxEffect:(BOOL)parallaxEffect
{
    //
    // Only update, if the value changed
    //
    
    if (_parallaxEffect != parallaxEffect)
    {
        _parallaxEffect = parallaxEffect;
        
        //
        // Notify delegate to update Parallax setting
        //
        
        if (self.delegate)
        {
            [self.delegate layerDidChangeParallaxEffect:self parallaxEffect:parallaxEffect];
        }
    }
}

- (void)setEffect:(DRImageEffect *)effect
{
    if (_effect != effect)
    {
        _effect = effect;
    }
    
    //
    // Notify delegate to update Blur Effect
    //
    
    if (self.delegate)
    {
        [self.delegate layerDidUpdateImageEffect:self imageEffect:effect];
    }
}

- (void)setOverlayMask:(UIBezierPath *)overlayMask
{
    if (_overlayMask != overlayMask)
    {
        _overlayMask = overlayMask;
    }
    
    //
    // Notify delegate to update Blur overlay mask
    //
    
    if (self.delegate)
    {
        [self.delegate layerDidUpdateOverlayMask:self overlayMask:overlayMask];
    }
}

- (void)setMaskPosition:(CGPoint)maskPosition
{
    _maskPosition = maskPosition;
    
    if (self.delegate)
    {
        [self.delegate layerDidUpdateMaskPosition:self maskPosition:maskPosition];
    }
}

- (void)setInverseMask:(BOOL)inverseMask
{
    if (_inverseMask != inverseMask)
    {
        _inverseMask = inverseMask;
        
        if (self.delegate)
        {
            [self.delegate layerDidUpdateOverlayMask:self overlayMask:nil];
        }
    }
}

- (void)updateLayer
{
    if (self.delegate)
    {
        [self.delegate layerDidUpdateContent:self];
    }
}

@end
