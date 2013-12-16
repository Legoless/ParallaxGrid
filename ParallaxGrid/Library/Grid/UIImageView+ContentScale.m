//
//  UIImageView+ContentScale.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/8/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "UIImageView+ContentScale.h"

@implementation UIImageView (ContentScale)

-(CGFloat)contentScaleFactor
{
    CGFloat widthScale = self.bounds.size.width / self.image.size.width;
    CGFloat heightScale = self.bounds.size.height / self.image.size.height;
    
    if (self.contentMode == UIViewContentModeScaleToFill)
    {
        return (widthScale==heightScale) ? widthScale : NAN;
    }
    
    if (self.contentMode == UIViewContentModeScaleAspectFit)
    {
        return MIN(widthScale, heightScale);
    }
    
    if (self.contentMode == UIViewContentModeScaleAspectFill)
    {
        return MAX(widthScale, heightScale);
    }
    return 1.0;
    
}


@end
