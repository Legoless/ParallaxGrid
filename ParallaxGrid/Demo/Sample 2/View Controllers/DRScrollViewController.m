//
//  DRScrollViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/8/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRScrollViewController.h"
#import "UIImage+ImageEffects.h"
#import "DRBlurEffect.h"

@interface DRScrollViewController () <UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

@implementation DRScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.effect = [DRBlurEffect lightEffect];
    self.parallaxEffect = NO;
    
    //UIBezierPath* mask = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(25.0, 25.0, 100.0, 100.0) cornerRadius:10.0];
    //[mask appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(150.0, 25.0, 100.0, 100.0) cornerRadius:10.0]];
    
    self.overlayMask = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(40.0, 150.0, 240.0, 240.0) cornerRadius:10];
    //self.inverseMask = YES;
    
    self.mainScrollView.delegate = self;
    
    
}
                                                 

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.mainScrollView.contentSize = CGSizeMake(320.0, 1200);
    
    [self updateBackground];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"DidScroll");
    
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = -contentOffset.y;
    
    self.maskPosition = contentOffset;
}

- (UIColor*)updateBackground
{
    //NSLog(@"Updating background: %@", [self.layerSource backgroundImage]);
    
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
        
        self.titleLabel.textColor = [UIColor blackColor];
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    else
    {
        blurEffect = [[DRBlurEffect alloc] initWithBlurEffect:[DRBlurEffect mildDarkEffect]];
        
        self.view.window.tintColor = [UIColor whiteColor];
        
        self.titleLabel.textColor = [UIColor whiteColor];

        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    blurEffect.scale = 1.0;
    blurEffect.image = sourceImage;
    self.effect = blurEffect;
    
    return self.view.window.tintColor;
}

@end
