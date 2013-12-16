//
//  DRBlurEffect.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRBlurEffect.h"
#import "GPUImage.h"

@import Accelerate;
#import <float.h>

@interface DRBlurEffect ()

@property (nonatomic, readwrite) CGFloat blurRadius;
@property (nonatomic, readwrite) UIColor* tintColor;
@property (nonatomic, readwrite) CGFloat saturationDeltaFactor;
@property (nonatomic, readwrite) UIImage* maskImage;

@end

@implementation DRBlurEffect

- (id)init
{
    return [self initWithBlurRadius:2.0 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

- (id)initWithBlurEffect:(DRBlurEffect *)blurEffect
{
    return [self initWithBlurRadius:blurEffect.blurRadius tintColor:[blurEffect.tintColor copy] saturationDeltaFactor:blurEffect.saturationDeltaFactor maskImage:[blurEffect.maskImage copy]];
}

- (id)initWithBlurRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage
{
    self = [super init];
    
    if (self)
    {
        self.blurRadius = blurRadius;
        self.tintColor = [tintColor copy];
        self.saturationDeltaFactor = saturationDeltaFactor;
        self.maskImage = [self.maskImage copy];
    }
    
    return self;
}

+ (DRBlurEffect*)mildLightEffect
{
    static DRBlurEffect* mildLightEffect = nil;
    static dispatch_once_t mildLightEffectToken;
    
    dispatch_once(&mildLightEffectToken, ^
                  {
                      mildLightEffect = [DRBlurEffect blurEffectWithRadius:2.0 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
                  });
    
    return mildLightEffect;
}


+ (DRBlurEffect*)lightEffect
{
    static DRBlurEffect* lightEffect = nil;
    static dispatch_once_t lightEffectToken;
    
    dispatch_once(&lightEffectToken, ^
    {
        lightEffect = [DRBlurEffect blurEffectWithRadius:30.0 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    });
    
    return lightEffect;
}

+ (DRBlurEffect*)extraLightEffect
{
    static DRBlurEffect* extraLightEffect = nil;
    static dispatch_once_t extraLightEffectToken;
    
    dispatch_once(&extraLightEffectToken, ^
                  {
                      extraLightEffect = [DRBlurEffect blurEffectWithRadius:20.0 tintColor:[UIColor colorWithWhite:0.97 alpha:0.82] saturationDeltaFactor:1.8 maskImage:nil];
                  });
    
    return extraLightEffect;
}

+ (DRBlurEffect*)darkEffect
{
    static DRBlurEffect* darkEffect = nil;
    static dispatch_once_t darkEffectToken;
    
    dispatch_once(&darkEffectToken, ^
                  {
                      darkEffect = [DRBlurEffect blurEffectWithRadius:20.0 tintColor:[UIColor colorWithWhite:0.11 alpha:0.73] saturationDeltaFactor:1.8 maskImage:nil];
                  });
    
    return darkEffect;
}

+ (DRBlurEffect*)mildDarkEffect
{
    static DRBlurEffect* mildLightEffect = nil;
    static dispatch_once_t mildLightEffectToken;
    
    dispatch_once(&mildLightEffectToken, ^
                  {
                      mildLightEffect = [DRBlurEffect blurEffectWithRadius:2.0 tintColor:[UIColor colorWithWhite:0.11 alpha:0.56] saturationDeltaFactor:1.5 maskImage:nil];
                  });
    
    return mildLightEffect;
}


+ (DRBlurEffect*)blurEffectWithTintColor:(UIColor*)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    
    UIColor *effectColor = tintColor;
    int componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    
    if (componentCount == 2)
    {
        CGFloat b;
        
        if ([tintColor getWhite:&b alpha:NULL])
        {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else
    {
        CGFloat r, g, b;
        
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL])
        {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    
    return [DRBlurEffect blurEffectWithRadius:10.0 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];

}

+ (DRBlurEffect*)blurEffectWithRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage
{
    return [[DRBlurEffect alloc] initWithBlurRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor maskImage:maskImage];
}

/*
- (UIImage*)applyEffect:(UIImage *)image
{
    GPUImagePicture* stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    
    //GPUImageGaussianBlurFilter* filter = [[GPUImageGaussianBlurFilter alloc] init];
    //filter.blurSize = 1.0;
    
    // Lanczos downsampling
    GPUImageLanczosResamplingFilter *lanczosResamplingFilter = [[GPUImageLanczosResamplingFilter alloc] init];
    [lanczosResamplingFilter forceProcessingAtSize:CGSizeMake(image.size.width * 0.5, image.size.height * 0.5)];
    [stillImageSource addTarget:lanczosResamplingFilter];
    //[stillImageSource processImage];
    //UIImage *lanczosImage = [lanczosResamplingFilter imageFromCurrentlyProcessedOutput];
    
    GPUImageFastBlurFilter* filter = [[GPUImageFastBlurFilter alloc] init];
    filter.blurPasses = 2;
    
    [stillImageSource addTarget:filter];
    [stillImageSource processImage];
    
    return [filter imageFromCurrentlyProcessedOutput];
}*/

/*
- (UIImage*)applyEffect:(UIImage *)image
{
    static EAGLContext* eaglContext;
    static CIContext* ctxt;
    
    if (!eaglContext)
    {
        NSLog(@"Creating eagl context");
        eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        ctxt = [CIContext contextWithEAGLContext:eaglContext options:@{kCIContextWorkingColorSpace: [NSNull null]}];
    }
    
    CIImage *newImage = [CIImage imageWithCGImage:image.CGImage];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:newImage forKey:kCIInputImageKey];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    UIImage* infiniteImage = [clampFilter valueForKey:kCIOutputImageKey];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:infiniteImage forKey:kCIInputImageKey];
    [filter setValue:@2.0 forKey:@"inputRadius"];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [ctxt createCGImage:result fromRect:[newImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
}*/

- (UIImage*)applyEffect:(UIImage *)image
{
    // Check pre-conditions.
    if (image.size.width < 1 || image.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", image.size.width, image.size.height, image);
        return nil;
    }
    if (!image.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", image);
        return nil;
    }
    if (self.maskImage && !self.maskImage.CGImage)
    {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", self.maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, image.size };
    UIImage *effectImage = image;
    
    BOOL hasBlur = self.blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(self.saturationDeltaFactor - 1.) > __FLT_EPSILON__;

    if (hasBlur || hasSaturationChange)
    {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -image.size.height);
        CGContextDrawImage(effectInContext, imageRect, image.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur)
        {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = self.blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            
            if (radius % 2 != 1)
            {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            
            vImageBoxConvolve_ARGB8888 (&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888 (&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888 (&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        
        if (hasSaturationChange)
        {
            CGFloat s = self.saturationDeltaFactor;
            
            CGFloat floatingPointSaturationMatrix[] =
            {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix) / sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            
            for (NSUInteger i = 0; i < matrixSize; ++i)
            {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            
            if (hasBlur)
            {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else
            {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -image.size.height);
    
    // Draw base image.
    //CGContextDrawImage(outputContext, imageRect, image.CGImage);
    
    // Draw effect image.
    if (hasBlur)
    {
        CGContextSaveGState(outputContext);
        
        if (self.maskImage)
        {
            CGContextClipToMask(outputContext, imageRect, self.maskImage.CGImage);
        }
        
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (self.tintColor)
    {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, self.tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
