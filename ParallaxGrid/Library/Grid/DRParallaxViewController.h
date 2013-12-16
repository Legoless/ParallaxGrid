//
//  DRParallaxViewController.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLayerViewController.h"

@interface DRParallaxViewController : UIViewController <DRLayerSource>

@property (nonatomic, strong) NSArray* layers;
@property (nonatomic, getter = hasParallaxEffect) BOOL parallaxEffect;

// Set background image for faster performance
@property (nonatomic, strong) UIImage* backgroundImage;
// Set background layer to let parallax know of your background content
@property (nonatomic, strong) UIViewController<DRLayerDelegate>* backgroundLayer;

// Add layer on top of hierarchy
- (void)addLayer:(UIViewController<DRLayerDelegate>*)layer;
// Add layer below another layer in hierarchy
- (void)addLayer:(UIViewController<DRLayerDelegate>*)layer belowLayer:(UIViewController<DRLayerDelegate>*)upperLayer;
// Add layer above layer in hierarchy
- (void)addLayer:(UIViewController<DRLayerDelegate>*)layer aboveLayer:(UIViewController<DRLayerDelegate>*)lowerLayer;

// Removes layer from hierarchy
- (void)removeLayer:(UIViewController<DRLayerDelegate>*)layer;
// Removes more layers from hierarchy (use as optimization)
- (void)removeLayers:(NSArray*)layers;
// Removes all layers in hierarchy
- (void)removeAllLayers;

@end
