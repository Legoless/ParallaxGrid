//
//  DRMiddleViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRMiddleViewController.h"
#import "DRBlurEffect.h"
#import "DRImageEffect.h"
#import "DRImageEffectLayer.h"
#import "UIImage+ImageEffects.h"

@interface DRMiddleViewController ()

@property (weak, nonatomic) IBOutlet UIView *descriptionOverlayView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;

@end

@implementation DRMiddleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.effect = [DRBlurEffect lightEffect];
    self.parallaxEffect = NO;
    
    //UIBezierPath* mask = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(25.0, 25.0, 100.0, 100.0) cornerRadius:10.0];
    //[mask appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(150.0, 25.0, 100.0, 100.0) cornerRadius:10.0]];
    
    self.overlayMask = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(40.0, 150.0, 240.0, 240.0)];
    self.inverseMask = YES;
    
    self.descriptionOverlayView.layer.cornerRadius = 10.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateBackground];
}
- (IBAction)update:(UIButton *)sender
{
    self.inverseMask = !self.inverseMask;
}

- (UIColor*)updateBackground
{
    NSLog(@"Updating background: %@", [self.layerSource backgroundImage]);
    
    DRImageEffect* dummyImageEffect = [[DRImageEffect alloc] init];
    UIImage* sourceImage = [dummyImageEffect mergeViewsToImage:[self.layerSource viewsBelowLayer:self toLayer:[self.layerSource backgroundLayer]] withBackgroundImage:[self.layerSource backgroundImage]];
    
    //
    // Setup effect
    //
    
    DRImageEffect* blurEffect = nil;
    
    double luminance = [sourceImage luminance];
    
    if (luminance > 0.5)
    {
        blurEffect = [[DRBlurEffect alloc] initWithBlurEffect:[DRBlurEffect mildLightEffect]];
        
        self.view.window.tintColor = [UIColor blackColor];
        
        self.descriptionOverlayView.backgroundColor = [UIColor whiteColor];
        self.descriptionOverlayView.alpha = 0.1;
        
        [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    else
    {
        blurEffect = [[DRBlurEffect alloc] initWithBlurEffect:[DRBlurEffect mildDarkEffect]];

        self.view.window.tintColor = [UIColor whiteColor];
        
        self.descriptionOverlayView.backgroundColor = [UIColor blackColor];
        self.descriptionOverlayView.alpha = 0.2;
        
        [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    blurEffect.scale = 1.0;
    blurEffect.image = sourceImage;
    self.effect = blurEffect;
    
    return self.view.window.tintColor;
}

@end
