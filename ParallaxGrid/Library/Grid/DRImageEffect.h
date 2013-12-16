//
//  DRImageEffect.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRImageEffect : NSObject

@property (strong, nonatomic) UIImage* image;

//
// Applies effect to scaled image
// This is used as a performance increase, which is needed in few cases (such as blur).
// Before effect is applied, image is downscaled and after applying the effect, it is
// upscaled to previous size. This of course causes the loss of quality in image.
//
// This method is not yet ready.
//
// Default: 1.0
//
@property (nonatomic) CGFloat scale;

- (id)initWithImage:(UIImage*)image;

// Abstract
- (UIImage *)applyEffect:(UIImage*)image;

- (UIImage *)applyEffectToView:(UIView*)view;

- (UIImage *)applyEffectToViews:(NSArray*)views;

- (UIImage *)applyEffectToViews:(NSArray*)views withBackgroundImage:(UIImage*)image;

- (UIImage *)applyEffectToViews:(NSArray*)views cropToView:(UIView*)view;

- (UIImage *)applyEffectToViews:(NSArray*)views withBackgroundImage:(UIImage*)image cropToView:(UIView*)view;

- (UIImage *)mergeViewsToImage:(NSArray*)views;

- (UIImage *)mergeViewsToImage:(NSArray*)views withBackgroundImage:(UIImage*)image;

@end
