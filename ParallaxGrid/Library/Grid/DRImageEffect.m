//
//  DRImageEffect.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRImageEffect.h"

@interface DRImageEffect ()

@end

@implementation DRImageEffect

- (id)init
{
    return [self initWithImage:nil];
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    
    if (self)
    {
        self.image = image;
        self.scale = 1.0;
    }
    
    return self;
}

- (UIImage *)applyEffect:(UIImage *)image
{
    // Abstract
    
    return nil;
}

- (UIImage *)applyEffectToView:(UIView *)view
{
    UIImage* imageWithView = [self imageWithView:view];
    
    return [self applyEffect:imageWithView];
}

- (UIImage *)applyEffectToViews:(NSArray *)views
{
    return [self applyEffectToViews:views withBackgroundImage:nil];
}

- (UIImage *)applyEffectToViews:(NSArray *)views withBackgroundImage:(UIImage *)image
{
    return [self applyEffectToViews:views withBackgroundImage:image cropToView:nil];
}

- (UIImage *)applyEffectToViews:(NSArray *)views cropToView:(UIView *)view
{
    return [self applyEffectToViews:views withBackgroundImage:nil cropToView:view];
}

- (UIImage *)applyEffectToViews:(NSArray *)views withBackgroundImage:(UIImage *)image cropToView:(UIView *)view
{
    UIImage* mergedImage = [self mergeViewsToImage:views withBackgroundImage:image cropToView:view];
    
    if (self.scale == 1.0)
    {
        return [self applyEffect:mergedImage];
    }
    else
    {
        UIImage* scaledImage = [UIImage imageWithCGImage:mergedImage.CGImage scale:self.scale orientation:UIImageOrientationDown];
        
        UIImage* effectImage = [self applyEffect:scaledImage];
        
        return [UIImage imageWithCGImage:effectImage.CGImage scale:(1.0 / self.scale) orientation:UIImageOrientationDown];
    }
}



- (UIImage *)mergeViewsToImage:(NSArray *)views
{
    return [self mergeViewsToImage:views withBackgroundImage:nil];
}

- (UIImage *)mergeViewsToImage:(NSArray *)views withBackgroundImage:(UIImage *)image
{
    return [self mergeViewsToImageFromArray:views withBackgroundImage:image cropToView:nil];
}


- (UIImage *)mergeViewsToImage:(NSArray *)views withBackgroundImage:(UIImage *)image cropToView:(UIView*)view
{
    //
    // Will return cached image if it has one.
    //
    
    if (self.image)
    {
        return self.image;
    }
    
    return [self mergeViewsToImageFromArray:views withBackgroundImage:image cropToView:view];
}


- (UIImage *)mergeViewsToImageFromArray:(NSArray *)views withBackgroundImage:(UIImage*)image cropToView:(UIView*)view
{
   // NSLog(@"Merging views from array: %d", [views count]);
    
    if (![views count] && !image)
    {
        return nil;
    }
    
    // Force redraw
    //[CATransaction flush];
    
    CGSize size = CGSizeZero;
    CGRect drawRect = CGRectZero;
    
    //
    // Crop view if required
    //
    
    if (view)
    {
        size = view.frame.size;
        drawRect = view.bounds;
    }
    else
    {
        //
        // Create images from views
        //
        
        for (UIView* view in views)
        {
            if (size.width < view.bounds.size.width)
            {
                size.width = view.bounds.size.width;
            }
            
            if (size.height < view.bounds.size.height)
            {
                size.height = view.bounds.size.height;
            }
        }
        
        //
        // Handle image if it is present
        //
        
        if (image)
        {
            if (image.size.width > size.width)
            {
                size.width = image.size.width;
            }
            
            if (image.size.height > size.height)
            {
                size.height = image.size.height;
            }
        }
        
        drawRect = CGRectMake(0.0, 0.0, size.width, size.height);
        //drawRect = view.frame;
    }
    
    /*
    NSString* filename = [NSString stringWithFormat:@"Documents/Test %@.png", [NSDate date]];
    
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:NO];*/
    
    //
    // Draw hiearchy in single image (combine multiple images)
    //
    
    UIImage* newImage = nil;

    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    //
    // Resize the rect by scale factor
    //
    
    if (image)
    {
        //CALayer* layer = [CALayer layer];
        //layer.contents = (__bridge id)(image.CGImage);
        
        //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        
        //[imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        //[imageView sizeToFit];
        
        //[[imageView snapshotView] drawViewHierarchyInRect:drawRect];
        
        /*UIView* view = [[UIView alloc] initWithFrame:drawRect];
        [view.layer addSublayer:layer];
        [view drawViewHierarchyInRect:drawRect];*/
        
        //[layer renderInContext:UIGraphicsGetCurrentContext()];
        
        
        //NSLog(@"Drawing image to rect: %@ view count: %d", image, [views count]);
        
        //[image drawInRect:drawRect];
        
        //
        // GPUImage if it would work faster
        //
        
        /*
        GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:drawRect];
        GPUImagePicture* imagePicture = [[GPUImagePicture alloc] initWithImage:image];
        
        [imagePicture addTarget:imageView];
        [imagePicture processImage];
        
        [imageView drawViewHierarchyInRect:drawRect];*/
    }
    
    for (UIView* subview in views)
    {
        //
        // Check if there is an UIImageView in views, in that case, we will render in context,
        // until Apple has decided to fix the bug themselves.
        //
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), drawRect.origin.x, drawRect.origin.y);
        
        if ([self viewContains:subview viewOfType:[UIImageView class]])
        {
            //[subview.layer renderInContext:UIGraphicsGetCurrentContext()];
            //
            
            [subview drawViewHierarchyInRect:drawRect afterScreenUpdates:YES];
        }
        else
        {
            //subview.frame = CGRectMake(0.0, 400, subview.frame.size.width, subview.frame.size.height);
            //[subview.layer renderInContext:UIGraphicsGetCurrentContext()];
            
            //[CATransaction flush];
            
            [subview drawViewHierarchyInRect:drawRect afterScreenUpdates:YES];
        }
    }
    
    NSLog(@"Draw to rect: %@", NSStringFromCGRect(drawRect));
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return newImage;
}

- (BOOL)viewContains:(UIView*)view viewOfType:(Class)type
{
    //
    // Check if our view is type
    //
    if ([view isKindOfClass:type])
    {
        return YES;
    }
    
    //
    // Check subviews
    //
    for (UIView* subview in view.subviews)
    {
        if ([self viewContains:subview viewOfType:type])
        {
            return YES;
        }
    }
    
    return NO;
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //UIGraphicsBeginImageContextWithOptions(view.bounds.size, NULL, 0);
    
    //[view drawViewHierarchyInRect:view.bounds];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
