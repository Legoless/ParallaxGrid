//
//  DRImageEffectLayer.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLayerViewController.h"
#import "DRLayerSource.h"

@interface DRImageEffectLayer : UIView

@property (nonatomic, weak) id<DRLayerSource> layerSource;
@property (nonatomic, readonly) UIViewController<DRLayerDelegate>* mainLayer;
@property (nonatomic, readonly) UIImageView* imageView;

//
// Pass layer source, because rendered image needs access to lower layers
//

- (id)initWithLayer:(UIViewController<DRLayerDelegate>*)layer source:(id<DRLayerSource>)layerSource;

- (void)renderLayerEffect;
- (void)updateLayerMask;
- (void)updateLayerMaskPosition;

@end
