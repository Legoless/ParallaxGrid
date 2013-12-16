//
//  UIImage+ImageEffects.h
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)

- (unsigned char*) grayscalePixels;
- (const unsigned char*) rgbaPixels;
- (UIColor*)averageColor;
- (double)luminance;
@end
