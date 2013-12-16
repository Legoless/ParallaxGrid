//
//  DRLayerSource.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRLayerSource <NSObject>

//
// Layers in the source
//

@property (nonatomic, strong) NSArray* layers;

//
// Allows you to set background image to layer source (much faster performance).
// The image is only used as a background for effect layers - if effect of the layer
// is not set, it will not be rendered to save power. Use UIImageView in a background
// layer to show "active" background.
//

@property (nonatomic, strong) UIImage* backgroundImage;

//
// If background image comes from a background layer, set this property to the layer
// that is the owner of the image. That way the layer will not be rendered on top of the
// background image.
//
// If the backgroundImage property is not set, setting backgroundLayer will have no
// performance impact, nor it will render any differently.
//

@property (nonatomic, strong) id backgroundLayer;

- (NSArray*)viewsBelowLayer:(id)layer;
- (NSArray*)viewsBelowLayer:(id)belowLayer toLayer:(id)toLayer;

- (BOOL)hasViewInTopLevel:(UIView*)view;

@end
