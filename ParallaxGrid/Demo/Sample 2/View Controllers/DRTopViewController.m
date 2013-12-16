//
//  DRTopViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/8/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRTopViewController.h"
#import "DRBackgroundViewController.h"
#import "DRScrollViewController.h"
#import "DRBlurEffect.h"

@interface DRTopViewController ()

@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIView *descriptionOverlayView;

@end

@implementation DRTopViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.effect = [DRBlurEffect mildDarkEffect];
}

- (IBAction)update:(UIButton *)sender
{
    NSArray* array = [self.layerSource layers];
    
    DRBackgroundViewController * backgroundVC = nil;
    DRScrollViewController* middleVC = nil;
    
    for (DRLayerViewController* layer in array)
    {
        if ([layer isKindOfClass:[DRBackgroundViewController class]])
        {
            backgroundVC = (DRBackgroundViewController*)layer;
        }
        
        if ([layer isKindOfClass:[DRScrollViewController class]])
        {
            middleVC = (DRScrollViewController*)layer;
        }
    }
    
    [backgroundVC changeBackground];
    
    UIColor* color = [middleVC updateBackground];
    
    [sender setTitleColor:color forState:UIControlStateNormal];
}

@end
