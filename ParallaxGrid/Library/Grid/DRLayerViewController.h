//
//  DRLayerViewController.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLayerDelegate.h"

@interface DRLayerViewController : UIViewController<DRLayerDelegate>

// Delegate and source
@property (nonatomic, weak) id<DREffectDelegate> delegate;
@property (nonatomic, weak) id<DRLayerSource> layerSource;

// Adds motion based parallax effect to layer
@property (nonatomic, getter = hasParallaxEffect) BOOL parallaxEffect;

// Add image effect, such as blur
@property (nonatomic, strong) DRImageEffect* effect;

// The overlay mask (image effect is shown only on mask)
@property (nonatomic, strong) UIBezierPath* overlayMask;

// Mask's position
@property (nonatomic) CGPoint maskPosition;

// Whether overlay mask should be reversed, so shapes inside represent holes
@property (nonatomic, getter = hasInverseMask) BOOL inverseMask;

// Function will render effects in layers above current
- (void)updateLayer;

@end
