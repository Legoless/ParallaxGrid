//
//  DRParallaxViewController.m
//  ParallaxGrid
//
//  Created by Dal Rupnik on 7/1/13.
//  Copyright (c) 2013 Dal Rupnik. All rights reserved.
//

#import "DRParallaxViewController.h"
#import "DRImageEffectLayer.h"

#define MAX_HORIZONTAL_PARALLAX_EFFECT 50.0
#define MAX_VERTICAL_PARALLAX_EFFECT 50.0

@interface DRParallaxViewController () <DREffectDelegate>

@property (nonatomic, strong) NSMutableArray* layerCache;
@property (nonatomic, strong) NSMutableArray* effectCache;

@property (nonatomic, getter = hasAppeared) BOOL appeared;

@end

@implementation DRParallaxViewController

//
// Lazy instantiation
//

- (NSMutableArray*)layerCache
{
    if (!_layerCache)
    {
        _layerCache = [[NSMutableArray alloc] init];
    }
    
    return _layerCache;
}

- (NSMutableArray*)effectCache
{
    if (!_effectCache)
    {
        _effectCache = [[NSMutableArray alloc] init];
    }
    
    return _effectCache;
}

- (NSArray*)layers
{
    return [self.layerCache copy];
}

- (void)setParallaxEffect:(BOOL)parallaxEffect
{
    if (_parallaxEffect != parallaxEffect)
    {
        _parallaxEffect = parallaxEffect;
        
        if (self.view.window)
        {
            [self setupParallax];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parallaxEffect = YES;
}

- (void)viewLoadLayers
{
    //
    // This method is only run if there are no layers added programatically before viewDidLoad is called.
    // Attempt to load layers from embedded view controllers.
    //
    
    self.layerCache = [self.childViewControllers mutableCopy];
    
    for (UIViewController<DRLayerDelegate>* layerViewController in self.layerCache)
    {
        layerViewController.delegate = self;
        layerViewController.layerSource = self;
    }
}

//
// View will appear checks current layer structure
//

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //
    // If we do not have layers, try to wire them in from childView controllers
    //
    
    if (![self.layerCache count])
    {
        [self viewLoadLayers];
    }
    
    if (![self.layerCache count])
    {
        return;
    }
    
    //
    // Keep EffectCache in sync
    //
    
    if (![self.effectCache count])
    {
        for (int i = 0; i < [self.layerCache count]; i++)
        {
            [self.effectCache addObject:[NSNull null]];
        }
    }
    
    [self setupEffects];
    [self setupParallax];
    
    self.appeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.appeared = NO;
}

- (void)setupEffects
{
    for (UIViewController* viewController in self.layerCache)
    {
        [self setupEffectForLayer:viewController];
    }
}

- (void)setupParallax
{
    CGSize parallaxSize = [self getMaxParallaxSize];
    
    //
    // Go through layers and perform effects and Parallax
    //
    
    for (UIViewController* viewController in self.layerCache)
    {
        // Make sure effects are setuped prior to setupping Parallax, or it will not work on effect layers
        [self setupParallaxForLayer:viewController withParallaxSize:parallaxSize];
    }
}

- (void)setupParallaxForLayer:(UIViewController*)viewController withParallaxSize:(CGSize)size
{
    BOOL parallax = YES;
    
    //
    // If it is a layer view controller, take the overriden setting for Parallax
    //
    
    if ([viewController conformsToProtocol:@protocol(DRLayerDelegate)])
    {
        id<DRLayerDelegate> layerViewController = (id<DRLayerDelegate>)viewController;
        
        parallax = [layerViewController hasParallaxEffect];
    }

    if ([self.layerCache indexOfObject:viewController] == [self.layerCache count] - 1)
    {
        parallax = NO;
    }
    
    if (!self.hasParallaxEffect)
    {
        parallax = NO;
    }
    
    //
    // Index serves for parallax calculation and finding image effect layer
    //
    
    NSInteger index = [self.layerCache indexOfObject:viewController];
    
    //
    // If we should apply parallax effect
    //
    
    //NSLog(@"Setuping Parallax for layer: %@, Status: %d", viewController, parallax);
    
    if (parallax)
    {
        //
        // Only create new interpolating effects if views are not added
        //
        
        UIInterpolatingMotionEffect *xAxis = nil;
        UIInterpolatingMotionEffect *yAxis = nil;
        
        UIMotionEffectGroup *group = nil;
        
        if (![viewController.view.motionEffects count])
        {
            xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            
            yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            
            group = [[UIMotionEffectGroup alloc] init];
            group.motionEffects = @[xAxis, yAxis];
            
            [viewController.view addMotionEffect:group];
        }
        else
        {
            //
            // Pull out correct interpolation motion effects, we are going to assume that no other motion effects
            // are applied, for now.
            //
            group = viewController.view.motionEffects[0];
            
            xAxis = group.motionEffects[0];
            yAxis = group.motionEffects[1];
        }
        
        
        //
        // Add motion effect to layer's blurred view if it has one
        //
        
        if ([viewController conformsToProtocol:@protocol(DRLayerDelegate)])
        {
            //
            // Parallax Effect must be visible on layer above, not layer below!
            //
            
            if ( (index + 1) < [self.effectCache count])
            {
                if (self.effectCache[index + 1] != [NSNull null])
                {
                    DRImageEffectLayer* effectLayer = self.effectCache[index + 1];
                    
                    if (![effectLayer.imageView.motionEffects count])
                    {
                        [effectLayer.imageView addMotionEffect:group];
                    }
                }
            }
        }
        
        CGFloat horizontalParallaxStep = size.width / [self.layerCache count];
        CGFloat verticalParallaxStep = size.height / [self.layerCache count];
        
        CGFloat currentHorizontalParallax = (size.width - (horizontalParallaxStep * index));
        CGFloat currentVerticalParallax = (size.height - (verticalParallaxStep * index));
        
        xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-currentHorizontalParallax];
        xAxis.maximumRelativeValue = [NSNumber numberWithFloat:currentHorizontalParallax];
        
        yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-currentVerticalParallax];
        yAxis.maximumRelativeValue = [NSNumber numberWithFloat:currentVerticalParallax];
    }
    else
    {
        //
        // We should disable Parallax effect
        //
        
        if ([viewController.view.motionEffects count])
        {
            NSArray* motionEffects = [viewController.view.motionEffects copy];
            
            for (UIMotionEffect* motionEffect in motionEffects)
            {
                [viewController.view removeMotionEffect:motionEffect];
            }
            
            //
            // Check if its proper class
            //
            
            if ([viewController conformsToProtocol:@protocol(DRLayerDelegate)])
            {
                if (self.effectCache[index] != [NSNull null])
                {
                    UIImageView* imageView = self.effectCache[index];
                    NSArray* imageLayerMotionEffects = [imageView.motionEffects copy];
                    
                    for (UIMotionEffect* motionEffect in imageLayerMotionEffects)
                    {
                        [imageView removeMotionEffect:motionEffect];
                    }
                }
            }
        }
    }
}

- (CGSize)getMaxParallaxSize
{
    //
    // Setup Parallax effect by taking deepest layer's size and calculate max parallax, so there is nothing visible
    // behind deepest layer.
    //
    
    CGFloat currentHorizontalParallax = MAX_HORIZONTAL_PARALLAX_EFFECT;
    CGFloat currentVerticalParallax = MAX_VERTICAL_PARALLAX_EFFECT;
    
    if (self.hasParallaxEffect)
    {
        //
        // Take deepest layer and get it's size, calculate max parallax based on that size
        //
        
        UIViewController* deepestLayer = self.layerCache[0];
        
        currentVerticalParallax = deepestLayer.view.frame.size.height - [[UIScreen mainScreen] bounds].size.height;
        currentVerticalParallax = currentVerticalParallax / 2.0;
        
        currentHorizontalParallax = deepestLayer.view.frame.size.width - [[UIScreen mainScreen] bounds].size.width;
        currentHorizontalParallax = currentHorizontalParallax / 2.0;
        
        if (currentVerticalParallax > MAX_VERTICAL_PARALLAX_EFFECT)
        {
            currentVerticalParallax = MAX_VERTICAL_PARALLAX_EFFECT;
        }
        
        if (currentHorizontalParallax > MAX_HORIZONTAL_PARALLAX_EFFECT)
        {
            currentHorizontalParallax = MAX_HORIZONTAL_PARALLAX_EFFECT;
        }
    }
    
    return CGSizeMake(currentHorizontalParallax, currentVerticalParallax);

}

- (void)setupEffectForLayer:(UIViewController*)viewController
{
    //
    // Index serves for parallax calculation and finding image effect layer
    //
    
    NSInteger index = [self.layerCache indexOfObject:viewController];
    
    //
    // Check if its proper class
    //
    
    if ([viewController conformsToProtocol:@protocol(DRLayerDelegate)])
    {
        UIViewController<DRLayerDelegate>* layerViewController = (UIViewController<DRLayerDelegate>*)viewController;
        
        //
        // If we have an effect, we shall recreate or update the layer
        //
        
        if (layerViewController.effect)
        {
            //
            // Create new effect layer or hammer down the update
            //
            
            if (self.effectCache[index] == [NSNull null])
            {
                self.effectCache[index] = [[DRImageEffectLayer alloc] initWithLayer:layerViewController source:self];
                
                if ([self.view.subviews containsObject:viewController.view])
                {
                    [self.view insertSubview:self.effectCache[index] belowSubview:viewController.view];
                }
                else if ([self.view.subviews containsObject:viewController.view.superview])
                {
                    [self.view insertSubview:self.effectCache[index] belowSubview:viewController.view.superview];
                }
            }
        }
        else
        {
            //
            // If we have previously rendered the effect, remove it now to save memory
            //
            
            if (self.effectCache[index] != [NSNull null])
            {
                UIView* view = self.effectCache[index];
                
                [view removeFromSuperview];
                
                self.effectCache[index] = [NSNull null];
            }
        }
    }
}

- (void)addLayer:(UIViewController<DRLayerDelegate>*)layer
{
    [self addLayer:layer aboveLayer:[self.layerCache lastObject]];
}

- (void)addLayer:(UIViewController<DRLayerDelegate>*)layer belowLayer:(UIViewController<DRLayerDelegate>*)upperLayer
{
    NSInteger upperLayerIndex = [self.layerCache indexOfObject:upperLayer];
    
    [self addLayer:layer belowLayer:self.layerCache[upperLayerIndex - 1]];
}

- (void)addLayer:(UIViewController<DRLayerDelegate>*)layer aboveLayer:(UIViewController<DRLayerDelegate>*)lowerLayer
{
    NSInteger lowerLayerIndex = [self.layerCache indexOfObject:lowerLayer];
    
    //
    // If it is at top, might as well add object instead of insert
    //
    
    if (lowerLayerIndex == [self.layerCache count] - 1)
    {
        [self.layerCache addObject:layer];
        [self.effectCache addObject:[NSNull null]];
    }
    else
    {
        [self.layerCache insertObject:layer atIndex:lowerLayerIndex + 1];
        [self.effectCache insertObject:[NSNull null] atIndex:lowerLayerIndex + 1];
    }
    
    //
    // Configure the delegate
    //
    
    layer.delegate = self;
    layer.layerSource = self;
    
    //
    // Add layer's view to view hiearchy
    //
    
    [self.view insertSubview:layer.view aboveSubview:lowerLayer.view];
    
    //
    // Setup layer
    //
    
    [self setupEffectForLayer:layer];
    
    //
    // Need to resetup Parallax, because the perspecitve is changed due to new layer
    //
    
    [self setupParallax];
}

- (void)removeLayer:(UIViewController<DRLayerDelegate>*)layer
{
    //
    // Remove superviews
    //
    
    NSInteger index = [self.layerCache indexOfObject:layer];
    
    [layer.view removeFromSuperview];
    
    if (self.effectCache[index] != [NSNull null])
    {
        UIView* view = self.effectCache[index];
        
        [view removeFromSuperview];
        
        [self.effectCache removeObjectAtIndex:index];
    }
    
    [self.layerCache removeObjectAtIndex:index];
    
    //
    // Check if it was in child view controllers
    //
    
    if ([self.childViewControllers containsObject:layer])
    {
        [layer removeFromParentViewController];
    }
    
    //
    // Need to resetup Parallax, because the perspecitve is changed due to new layer
    //
    
    [self setupParallax];
}

- (void)removeLayers:(NSArray *)layers
{
    for (UIViewController<DRLayerDelegate>* layer in layers)
    {
        [self removeLayer:layer];
    }
}

- (void)removeAllLayers
{
    [self removeLayers:self.layers];
}

- (void)layerDidUpdateContent:(id)layer
{
    if (!self.hasAppeared)
    {
        return;
    }
    
    NSInteger index = [self.layerCache indexOfObject:layer];
    
    //
    // Layer updated content, so delegate's responsibility is to update layers higher in hierarchy
    //
    
    [self updateLayersAboveIndex:index];
}

- (void)layerDidChangeParallaxEffect:(id)layer parallaxEffect:(BOOL)parallaxEffect
{
    if (!self.hasAppeared)
    {
        return;
    }
    
    //
    // Layer changed Parallax effect setting, only setup Parallax for specific layer
    //
    
    [self setupParallaxForLayer:layer withParallaxSize:[self getMaxParallaxSize]];
}

- (void)layerDidUpdateImageEffect:(id)layer imageEffect:(DRImageEffect *)imageEffect
{
    if (!self.hasAppeared)
    {
        return;
    }
    
    NSInteger index = [self.layerCache indexOfObject:layer];
    
    //
    // Layer changed image effect, update only effect
    //
    
    [self setupEffectForLayer:layer];
    
    if (imageEffect)
    {
        DRImageEffectLayer* effectLayer = self.effectCache[index];
        
        [effectLayer renderLayerEffect];
        
        if (index > 0)
        {
            [self setupParallaxForLayer:[self.layerCache objectAtIndex:index - 1] withParallaxSize:[self getMaxParallaxSize]];
        }
    }
    
    //
    // Also update effects above layer
    //
    
    [self updateLayersAboveIndex:index];
}

- (void)updateLayersAboveIndex:(NSInteger)index
{
    for (int i = index + 1; i < [self.layerCache count]; i++)
    {
        if (self.effectCache[i] != [NSNull null])
        {
            DRImageEffectLayer* effectAboveLayer = self.effectCache[i];
            [effectAboveLayer renderLayerEffect];
        }
    }
}

- (void)layerDidUpdateOverlayMask:(id)layer overlayMask:(UIBezierPath *)overlayMask
{
    if (!self.hasAppeared)
    {
        return;
    }
    
    //
    // Layer changed image effect, update only effect
    //
    
    NSInteger index = [self.layerCache indexOfObject:layer];
    
    if (self.effectCache[index] != [NSNull null])
    {
        DRImageEffectLayer* effectLayer = self.effectCache[index];
        [effectLayer updateLayerMask];
        
        [self updateLayersAboveIndex:index];
    }
}

- (void)layerDidUpdateMaskPosition:(id)layer maskPosition:(CGPoint)maskPosition
{
    if (!self.hasAppeared)
    {
        return;
    }
    
    //
    // Layer changed image effect, update only effect
    //
    
    NSInteger index = [self.layerCache indexOfObject:layer];
    
    if (self.effectCache[index] != [NSNull null])
    {
        DRImageEffectLayer* effectLayer = self.effectCache[index];
        [effectLayer updateLayerMaskPosition];
        
        [self updateLayersAboveIndex:index];
    }
}

- (NSArray*)viewsBelowLayer:(id)layer
{
    return [self viewsBelowLayer:layer toLayer:nil];
}

- (NSArray*)viewsBelowLayer:(id)topLayer toLayer:(id)bottomLayer
{
    //
    // Returns all views that are below layer in hiearchy
    //
    
    UIViewController<DRLayerDelegate>* topLayerVC = topLayer;
    UIViewController<DRLayerDelegate>* bottomLayerVC = bottomLayer;
    
    //
    // Get both indexes of top layer and bottom layer VC (handle containers)
    //
    
    NSInteger topLayerIndex = 0;
    
    if ([self.view.subviews containsObject:topLayerVC.view])
    {
        topLayerIndex = [self.view.subviews indexOfObject:topLayerVC.view];
    }
    else if ([self.view.subviews containsObject:topLayerVC.view.superview])
    {
        topLayerIndex = [self.view.subviews indexOfObject:topLayerVC.view.superview];
    }
    
    //
    // Can be nil, ensure not to search for nil in array
    //
    
    NSInteger bottomLayerIndex = -1;
    
    if (bottomLayerVC)
    {
        if ([self.view.subviews containsObject:bottomLayerVC.view])
        {
            bottomLayerIndex = [self.view.subviews indexOfObject:bottomLayerVC.view];
        }
        else if ([self.view.subviews containsObject:bottomLayerVC.view.superview])
        {
            bottomLayerIndex = [self.view.subviews indexOfObject:bottomLayerVC.view.superview];
        }
    }

    
    //
    // The effect is also part of layer, so if it has one, skip the effect layer of the top layer
    //
    
    if (topLayerVC.effect)
    {
        topLayerIndex--;
    }
    
    /*
    if (bottomLayerVC.effect)
    {
        bottomLayerIndex--;
    }*/
    
    return [self.view.subviews subarrayWithRange:NSMakeRange(bottomLayerIndex + 1, topLayerIndex - (bottomLayerIndex + 1))];
}

- (BOOL)hasViewInTopLevel:(UIView *)view
{
    return [self.view.subviews containsObject:view];
}


@end
