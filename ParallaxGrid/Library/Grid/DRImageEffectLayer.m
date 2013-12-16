//
//  DRImageEffectLayer.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DRImageEffectLayer.h"

@interface DRImageEffectLayer ()

@property (nonatomic, readwrite, weak) UIViewController<DRLayerDelegate>* mainLayer;
@property (nonatomic, readwrite) UIImageView* imageView;

@end

@implementation DRImageEffectLayer

// Override super's init with frame, to make sure you cannot initialize the effect layer
- (id)initWithFrame:(CGRect)frame
{
    return nil;
}

// Do not allow image effect layer with only image
- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    return nil;
}

- (id)initWithLayer:(UIViewController<DRLayerDelegate>*)layer source:(id)layerSource
{
    self = [super initWithFrame:layer.view.frame];
    
    if (self)
    {
        self.mainLayer = layer;
        self.layerSource = layerSource;
        
        if ([layerSource hasViewInTopLevel:layer.view])
        {
            self.frame = layer.view.frame;
            
            self.imageView = [[UIImageView alloc] initWithFrame:layer.view.bounds];
        }
        else
        {
            self.frame = layer.view.superview.frame;
            
            self.imageView = [[UIImageView alloc] initWithFrame:layer.view.superview.bounds];
        }
        
        [self addSubview:self.imageView];
        
        //NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
        //NSLog(@"Image Frame: %@", NSStringFromCGRect(self.imageView.frame));
        
        [self renderLayerEffect];
        [self updateLayerMask];
    }
    
    return self;
}

- (void)renderLayerEffect
{
    if (self.mainLayer.effect)
    {
        //
        // Support backgroundImage API
        //
        
        if ([self.layerSource backgroundImage])
        {
            NSArray* layers = [self.layerSource viewsBelowLayer:self.mainLayer toLayer:[self.layerSource backgroundLayer]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
            ^{
                UIImage* renderedImage = nil;
            
                if ([self.layerSource hasViewInTopLevel:self.mainLayer.view])
                {
                    renderedImage = [self.mainLayer.effect applyEffectToViews:layers withBackgroundImage:[self.layerSource backgroundImage] cropToView:self.mainLayer.view];
                    NSLog(@"Rendered layer effect with background image: %@, but cropped to: %@, layer count: %d", [self.layerSource backgroundImage], NSStringFromCGRect(self.mainLayer.view.superview.frame), [layers count]);
                }
                else
                {
                    renderedImage = [self.mainLayer.effect applyEffectToViews:layers withBackgroundImage:[self.layerSource backgroundImage] cropToView:self.mainLayer.view.superview];
                    
                     NSLog(@"Superview: Rendered layer effect with background image %@, but cropped to: %@, layer count: %d", [self.layerSource backgroundImage], NSStringFromCGRect(self.mainLayer.view.superview.frame), [layers count]);
                }
                
                
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    self.imageView.image = renderedImage;
                });
            });
        }
        else
        {
            NSArray* layers = [self.layerSource viewsBelowLayer:self.mainLayer];
            
            if ([self.layerSource hasViewInTopLevel:self.mainLayer.view])
            {
                self.imageView.image = [self.mainLayer.effect applyEffectToViews:layers cropToView:self.mainLayer.view];
                
                NSLog(@"Rendered layer effect without background image, but cropped to: %@, layer count: %d", NSStringFromCGRect(self.mainLayer.view.superview.frame), [layers count]);
            }
            else
            {
                self.imageView.image = [self.mainLayer.effect applyEffectToViews:layers cropToView:self.mainLayer.view.superview];
                
                NSLog(@"Superview: Rendered layer effect without background image, but cropped to: %@, layer count: %d", NSStringFromCGRect(self.mainLayer.view.superview.frame), [layers count]);
            }
        }

        [self.imageView sizeToFit];
        
        if (!CGRectIsEmpty(self.imageView.frame))
        {
            //
            // For Parallax, we need to fix bounds, to correctly position image if it is larger than default screen, so it is in the center of the screen
            //
            
            CGRect bounds = [[UIScreen mainScreen] bounds];
            
            CGFloat imageX = 0.0;
            CGFloat imageY = 0.0;
            
            if (self.imageView.frame.size.width > bounds.size.width)
            {
                imageX = fabs(self.imageView.frame.size.width - bounds.size.width) / 2.0;
            }
            
            if (self.imageView.frame.size.height > bounds.size.height)
            {
                imageY = fabs(self.imageView.frame.size.height - bounds.size.height) / 2.0;
            }
            
            
            CGPoint imageOrigin = CGPointMake(imageX, imageY);
            self.imageView.frame = CGRectMake(-imageOrigin.x, -imageOrigin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
        }
        
        //NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
        //NSLog(@"Image Frame: %@", NSStringFromCGRect(self.imageView.frame));
    }
}

- (void)updateLayerMask
{
    if (self.mainLayer.overlayMask)
    {
        CAShapeLayer* maskLayer = nil;
        
        if (!self.layer.mask)
        {
            maskLayer = [[CAShapeLayer alloc] init];
            
            //maskLayer.frame = [[UIScreen mainScreen] bounds];
            //maskLayer.anchorPoint = CGPointZero;
            maskLayer.fillRule = kCAFillRuleEvenOdd;
            //maskLayer.position = CGPointMake(fabs(self.frame.origin.x), fabs(self.frame.origin.y));
            self.layer.mask = maskLayer;
        }
        else
        {
            maskLayer = (CAShapeLayer*)self.layer.mask;
        }
        
        if (self.mainLayer.inverseMask)
        {
            UIBezierPath* reversedPath = [UIBezierPath bezierPathWithRect:self.frame];
            [reversedPath appendPath:self.mainLayer.overlayMask];
            
            maskLayer.path = reversedPath.CGPath;
        }
        else
        {
            //UIBezierPath* reversedPath = [UIBezierPath bezierPathWithRect:self.imageView.frame];
            //[reversedPath appendPath:self.mainLayer.overlayMask];
            
            //maskLayer.position = self.frame.origin;
            
            maskLayer.path = self.mainLayer.overlayMask.CGPath;
        }
        
        maskLayer.position = [self.mainLayer maskPosition];
        
        /*NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
        NSLog(@"Image Frame: %@", NSStringFromCGRect(self.imageView.frame));

        NSLog(@"Mask frame: %@", NSStringFromCGRect(maskLayer.frame));
        NSLog(@"Mask position: %@", NSStringFromCGPoint(maskLayer.position));*/
    }
}

- (void)updateLayerMaskPosition
{
    if (self.mainLayer.overlayMask)
    {
        CAShapeLayer* maskLayer = nil;
        
        if (!self.layer.mask)
        {
            maskLayer = [[CAShapeLayer alloc] init];
            
            //maskLayer.frame = [[UIScreen mainScreen] bounds];
            //maskLayer.anchorPoint = CGPointZero;
            maskLayer.fillRule = kCAFillRuleEvenOdd;
            //maskLayer.position = CGPointMake(fabs(self.frame.origin.x), fabs(self.frame.origin.y));
            self.layer.mask = maskLayer;
        }
        else
        {
            maskLayer = (CAShapeLayer*)self.layer.mask;
        }
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        maskLayer.position = [self.mainLayer maskPosition];
        
        [CATransaction commit];
    }
}

@end
