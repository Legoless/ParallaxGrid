//
//  UIImage+ImageEffects.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/2/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "UIImage+ImageEffects.h"

@implementation UIImage (ImageEffects)

-(unsigned char*) grayscalePixels
{
	// The amount of bits per pixel, in this case we are doing grayscale so 1 byte = 8 bits
#define BITS_PER_PIXEL 8
	// The amount of bits per component, in this it is the same as the bitsPerPixel because only 1 byte represents a pixel
#define BITS_PER_COMPONENT (BITS_PER_PIXEL)
	// The amount of bytes per pixel, not really sure why it asks for this as well but it's basically the bitsPerPixel divided by the bits per component (making 1 in this case)
#define BYTES_PER_PIXEL (BITS_PER_PIXEL/BITS_PER_COMPONENT)
	
	// Define the colour space (in this case it's gray)
	CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
	
	// Find out the number of bytes per row (it's just the width times the number of bytes per pixel)
	size_t bytesPerRow = self.size.width * BYTES_PER_PIXEL;
	// Allocate the appropriate amount of memory to hold the bitmap context
	unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*self.size.height);
	
	// Create the bitmap context, we set the alpha to none here to tell the bitmap we don't care about alpha values
	CGContextRef context = CGBitmapContextCreate(bitmapData, self.size.width, self.size.height, BITS_PER_COMPONENT, bytesPerRow, colourSpace, kCGBitmapAlphaInfoMask);
	
	// We are done with the colour space now so no point in keeping it around
	CGColorSpaceRelease(colourSpace);
	
	// Create a CGRect to define the amount of pixels we want
	CGRect rect = CGRectMake(0.0,0.0,self.size.width,self.size.height);
	// Draw the bitmap context using the rectangle we just created as a bounds and the Core Graphics Image as the image source
	CGContextDrawImage(context,rect,self.CGImage);
	// Obtain the pixel data from the bitmap context
	unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
	
	// Release the bitmap context because we are done using it
	CGContextRelease(context);
	
	// Test script
	/*
     for(int i=0;i<self.size.height;i++)
     {
     for(int y=0;y<self.size.width;y++)
     {
     NSLog(@"0x%X",pixelData[(i*((int)self.size.width))+y]);
     }
     }
	 */
	
	return pixelData;
#undef BITS_PER_PIXEL
#undef BITS_PER_COMPONENT
}

-(const unsigned char*) rgbaPixels
{
    CGImageRef image = [self CGImage];
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(image));
    const unsigned char * buffer =  CFDataGetBytePtr(data);
    
    return buffer;
}

/*
-(unsigned char*) rgbaPixels
{
	// The amount of bits per pixel, in this case we are doing RGBA so 4 byte = 32 bits
#define BITS_PER_PIXEL 32
	// The amount of bits per component, in this it is the same as the bitsPerPixel divided by 4 because each component (such as Red) is only 8 bits
#define BITS_PER_COMPONENT (BITS_PER_PIXEL/4)
	// The amount of bytes per pixel, in this case a pixel is made up of Red, Green, Blue and Alpha so it will be 4
#define BYTES_PER_PIXEL (BITS_PER_PIXEL/BITS_PER_COMPONENT)
	
	// Define the colour space (in this case it's gray)
	CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
	
	// Find out the number of bytes per row (it's just the width times the number of bytes per pixel)
	size_t bytesPerRow = self.size.width * BYTES_PER_PIXEL;
	// Allocate the appropriate amount of memory to hold the bitmap context
	unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*self.size.height);
	
	// Create the bitmap context, we set the alpha to none here to tell the bitmap we don't care about alpha values
	CGContextRef context = CGBitmapContextCreate(bitmapData,self.size.width,self.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
	
	// We are done with the colour space now so no point in keeping it around
	CGColorSpaceRelease(colourSpace);
	
	// Create a CGRect to define the amount of pixels we want
	CGRect rect = CGRectMake(0.0,0.0,self.size.width,self.size.height);
	// Draw the bitmap context using the rectangle we just created as a bounds and the Core Graphics Image as the image source
	CGContextDrawImage(context,rect,self.CGImage);
	// Obtain the pixel data from the bitmap context
	unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
	
	// Release the bitmap context because we are done using it
	CGContextRelease(context);
	
	return pixelData;
#undef BITS_PER_PIXEL
#undef BITS_PER_COMPONENT
}*/

- (UIColor *)averageColor
{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if (rgba[3] > 0)
    {
        CGFloat alpha = ((CGFloat)rgba[3]) / 255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier green:((CGFloat)rgba[1])*multiplier blue:((CGFloat)rgba[2])*multiplier alpha:alpha];
    }
    else
    {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0 green:((CGFloat)rgba[1])/255.0 blue:((CGFloat)rgba[2])/255.0 alpha:((CGFloat)rgba[3])/255.0];
    }
}


- (double)luminance
{
    
#define PIXEL_PARSE_THREAD_COUNT 800
    
    UIImage* image = self;
    __block const unsigned char* pixels = [image rgbaPixels];
    __block double totalLuminance = 0.0;
    __block NSInteger maxPixelCount = image.size.width * image.size.height * 4;
    
    dispatch_apply((size_t)ceil((double)maxPixelCount / (double)PIXEL_PARSE_THREAD_COUNT), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
    ^(size_t i)
    {
        totalLuminance += [self luminanceForPixels:pixels offset:i * PIXEL_PARSE_THREAD_COUNT count:PIXEL_PARSE_THREAD_COUNT max:maxPixelCount];
    });
    
    totalLuminance /= (image.size.width * image.size.height);
    totalLuminance /= 255.0;
    
    
    return totalLuminance;
}

/*
- (double)luminance
{
    
#define PIXEL_PARSE_THREAD_COUNT 100
    
    UIImage* image = self;
    const unsigned char* pixels = [image rgbaPixels];
    double totalLuminance = 0.0;

    for (int p = 0; p < image.size.width * image.size.height * 4; p += 4)
    {
        totalLuminance += pixels[p] * 0.299 + pixels[p + 1] * 0.587 + pixels[p + 2] * 0.114;
    }
    
    totalLuminance /= (image.size.width * image.size.height);
    totalLuminance /= 255.0;    
    
    return totalLuminance;
}
 */

- (double)luminanceForPixels:(const unsigned char*)pixels offset:(NSInteger)offset count:(NSInteger)count max:(NSInteger) max
{
    double luminance = 0.0;
    
    int maxCurrent = offset + count;
    
    if (maxCurrent > max)
    {
        maxCurrent = max;
    }
    
    for (int p = offset; p < offset + count; p += 4)
    {
        luminance += pixels[p] * 0.299 + pixels[p + 1] * 0.587 + pixels[p + 2] * 0.114;
    }
    
    return luminance;
}


@end
