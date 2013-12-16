//
//  DRBlurEffect.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRImageEffect.h"

@interface DRBlurEffect : DRImageEffect

@property (nonatomic, readonly) CGFloat blurRadius;
@property (nonatomic, readonly) UIColor* tintColor;
@property (nonatomic, readonly) CGFloat saturationDeltaFactor;
@property (nonatomic, readonly) UIImage* maskImage;

+ (DRBlurEffect*)mildLightEffect;
+ (DRBlurEffect*)lightEffect;
+ (DRBlurEffect*)extraLightEffect;
+ (DRBlurEffect*)darkEffect;
+ (DRBlurEffect*)mildDarkEffect;

+ (DRBlurEffect*)blurEffectWithTintColor:(UIColor*)tintColor;
+ (DRBlurEffect*)blurEffectWithRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage;

- (id)initWithBlurRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage;

- (id)initWithBlurEffect:(DRBlurEffect*)blurEffect;
@end
