//
//  DRBackgroundViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRBackgroundViewController.h"
#import "UIImageView+ContentScale.h"

@interface DRBackgroundViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray* imageArray;

@property (nonatomic) NSInteger counter;
@end

@implementation DRBackgroundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.parallaxEffect = YES;
    
    //
    // Load all image effects on load, so we get fluid UI transition later.
    //
    
    self.imageArray = @[[UIImage imageNamed:@"background1"], [UIImage imageNamed:@"background2"], [UIImage imageNamed:@"background3"], [UIImage imageNamed:@"background4"]];
}

- (void)changeBackground
{
    self.counter = (self.counter + 1) % [self.imageArray count];
    
    self.backgroundImageView.image = self.imageArray[self.counter];
    
    //[self.layerSource setBackgroundLayer:self];
    
    //
    // Using a backgroundImage, it must be properly rescaled (since UIImageView does not do the drawing)
    //
    
    /*if ([self.backgroundImageView contentScaleFactor] != 1.0)
    {
        UIImage* scaledImage = [UIImage imageWithCGImage:((UIImage*)self.imageArray[self.counter]).CGImage scale:1.0 / [self.backgroundImageView contentScaleFactor] orientation:UIImageOrientationDown];
        
        [self.layerSource setBackgroundImage:scaledImage];
    }
    else
    {*/
        //[self.layerSource setBackgroundImage:self.imageArray[self.counter]];
    //}
    
    NSLog(@"Image: %@ Counter: %d", self.backgroundImageView.image, self.counter);
}


@end
