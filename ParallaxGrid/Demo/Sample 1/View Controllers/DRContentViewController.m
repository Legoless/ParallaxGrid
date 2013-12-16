//
//  DRContentViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRContentViewController.h"
#import "DRBackgroundViewController.h"
#import "DRMiddleViewController.h"

@interface DRContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DRContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)changeBackground:(UIButton *)sender
{
    NSArray* array = [self.layerSource layers];

    DRBackgroundViewController * backgroundVC = nil;
    DRMiddleViewController* middleVC = nil;
    
    for (DRLayerViewController* layer in array)
    {
        if ([layer isKindOfClass:[DRBackgroundViewController class]])
        {
            backgroundVC = (DRBackgroundViewController*)layer;
        }
        
        if ([layer isKindOfClass:[DRMiddleViewController class]])
        {
            middleVC = (DRMiddleViewController*)layer;
        }
    }
    
    [backgroundVC changeBackground];
    
    UIColor* color = [middleVC updateBackground];

    [sender setTitleColor:color forState:UIControlStateNormal];
    self.descriptionLabel.textColor = color;
}

@end
