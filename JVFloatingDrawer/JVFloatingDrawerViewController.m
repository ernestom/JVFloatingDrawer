//
//  JVFloatingDrawerViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-11.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerView.h"
#import "JVFloatingDrawerAnimation.h"

//static NSString * const kJVCenterViewContainerShadowLayerName = @"Shadow";
static const CGFloat kJVCenterViewContainerCornerRadius = 5.0;

NSString *JVFloatingDrawerSideString(JVFloatingDrawerSide side) {
    const char* c_str = 0;
#define PROCESS_VAL(p) case(p): c_str = #p; break;
    switch(side) {
            PROCESS_VAL(JVFloatingDrawerSideNone);
            PROCESS_VAL(JVFloatingDrawerSideLeft);
            PROCESS_VAL(JVFloatingDrawerSideRight);
    }
#undef PROCESS_VAL
    
    return [NSString stringWithCString:c_str encoding:NSASCIIStringEncoding];
}

@interface JVFloatingDrawerViewController ()

@property (nonatomic, strong, readonly) JVFloatingDrawerView *drawerView;
@property (nonatomic, assign) JVFloatingDrawerSide currentlyOpenedSide;
@property (nonatomic, strong) UITapGestureRecognizer *toggleDrawerTapGestureRecognizer;

@end

@implementation JVFloatingDrawerViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.currentlyOpenedSide = JVFloatingDrawerSideNone;
}

#pragma mark - View Related

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadView {
    self.drawerView = [[JVFloatingDrawerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

// Convenience type-wrapper around self.view. Maybe not the best idea?
- (void)setDrawerView:(JVFloatingDrawerView *)drawerView {
    self.view = drawerView;
}

- (JVFloatingDrawerView *)drawerView {
    return (JVFloatingDrawerView *)self.view;
}

#pragma mark - Interaction

#warning Implement animated flag - doesn't acknowledge it currently

- (void)openDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
//    NSLog(@"Opening %@", JVFloatingDrawerSideString(drawerSide));
    
    if(self.currentlyOpenedSide != drawerSide) {
        UIView *sideView   = [self.drawerView viewContainerForDrawerSide:drawerSide];
        UIView *centerView = self.drawerView.centerViewContainer;
        
        // First close opened drawer and then open new drawer
        if(self.currentlyOpenedSide != JVFloatingDrawerSideNone) {
            [self closeDrawerWithSide:self.currentlyOpenedSide animated:YES completion:^(BOOL finished) {
                [self.animator presentationAnimationWithSide:drawerSide sideView:sideView centerView:centerView completion:completion];
            }];
        } else {
            [self.animator presentationAnimationWithSide:drawerSide sideView:sideView centerView:centerView completion:completion];
        }
        
        [self addDrawerGestures];
        
        [self applyBorderRadiusToCenterViewContainer];
        [self applyShadowToCenterViewContainer];
    }
    
    self.currentlyOpenedSide = drawerSide;
}

- (void)closeDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
//    NSLog(@"Closing %@", JVFloatingDrawerSideString(drawerSide));
    
    if(self.currentlyOpenedSide == drawerSide && self.currentlyOpenedSide != JVFloatingDrawerSideNone) {
        UIView *sideView   = [self.drawerView viewContainerForDrawerSide:drawerSide];
        UIView *centerView = self.drawerView.centerViewContainer;
        
        [self.animator dismissAnimationWithSide:drawerSide sideView:sideView centerView:centerView completion:completion];
        
        self.currentlyOpenedSide = JVFloatingDrawerSideNone;
        
        [self restoreGestures];
        
        [self removeBorderRadiusFromCenterViewContainer];
        [self removeShadowFromCenterViewContainer];
    }
}

- (void)toggleDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
    if(drawerSide != JVFloatingDrawerSideNone) {
        if(drawerSide == self.currentlyOpenedSide) {
            [self closeDrawerWithSide:drawerSide animated:animated completion:completion];
        } else {
            [self openDrawerWithSide:drawerSide animated:animated completion:completion];
        }
    }
}

#pragma mark - Gestures

- (void)addDrawerGestures {
    self.centerViewController.view.userInteractionEnabled = NO;
    self.toggleDrawerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionCenterViewContainerTapped:)];
    [self.drawerView.centerViewContainer addGestureRecognizer:self.toggleDrawerTapGestureRecognizer];
}

- (void)restoreGestures {
    [self.drawerView.centerViewContainer removeGestureRecognizer:self.toggleDrawerTapGestureRecognizer];
    self.toggleDrawerTapGestureRecognizer = nil;
    self.centerViewController.view.userInteractionEnabled = YES;    
}

- (void)actionCenterViewContainerTapped:(id)sender {
    [self closeDrawerWithSide:self.currentlyOpenedSide animated:YES completion:nil];
}


////////////////// REFACTOR ME //////////////////

- (void)applyBorderRadiusToCenterViewContainer {
    /*
    CALayer *centerLayer = self.drawerView.centerViewContainer.layer;
    centerLayer.borderColor = [UIColor clearColor].CGColor;
    centerLayer.borderWidth = 1.0;
    centerLayer.cornerRadius = kJVCenterViewContainerCornerRadius;
    self.drawerView.centerViewContainer.clipsToBounds = YES;
    */
}

- (void)removeBorderRadiusFromCenterViewContainer {
    /*
    CALayer *centerLayer = self.drawerView.centerViewContainer.layer;
    centerLayer.borderColor = [UIColor clearColor].CGColor;
    centerLayer.borderWidth = 0.0;
    centerLayer.cornerRadius = 0.0;
     */
//    self.drawerView.centerViewContainer.clipsToBounds = NO;
}

- (void)applyShadowToCenterViewContainer {
    CALayer *layer = self.drawerView.centerViewContainer.layer;
    layer.shadowRadius  = 8.0;
//    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.drawerView.centerViewContainer.frame
//                                                         cornerRadius:kJVCenterViewContainerCornerRadius] CGPath];
//    layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.drawerView.centerViewContainer.frame] CGPath];
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(100.0, 100.0, 100.0, 100.0)] CGPath];
    layer.shadowColor   = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 1.0;
    layer.shadowOffset  = CGSizeMake(0.0, 0.0);
//    shadowLayer.masksToBounds = NO;
//    shadowLayer.name = kJVCenterViewContainerShadowLayerName;
//    [self.drawerView.centerViewContainer.layer insertSublayer:shadowLayer atIndex:0];

    // TODO Move this out, not just related to shadows in specific, but that is why we are using it.
//    self.view.layer.shouldRasterize = YES;
//    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)removeShadowFromCenterViewContainer {
    CALayer *layer = self.drawerView.centerViewContainer.layer;
    layer.shadowRadius  = 0.0;
    layer.shadowOpacity = 0.0;
    
//    for(CALayer *layer in [NSArray arrayWithArray:self.drawerView.centerViewContainer.layer.sublayers]) {
//        if ([layer.name isEqualToString:kJVCenterViewContainerShadowLayerName]) {
//            [layer removeFromSuperlayer];
//        }
//    }
}

////////////////// REFACTOR ME //////////////////



#pragma mark - Managed View Controllers

- (void)setLeftViewController:(UIViewController *)leftViewController {
    [self replaceViewController:self.leftViewController
             withViewController:leftViewController container:self.drawerView.leftViewContainer];
    
    _leftViewController = leftViewController;
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    [self replaceViewController:self.rightViewController withViewController:rightViewController
                      container:self.drawerView.rightViewContainer];
    
    _rightViewController = rightViewController;
}

- (void)setCenterViewController:(UIViewController *)centerViewController {
    [self replaceViewController:self.centerViewController withViewController:centerViewController
                      container:self.drawerView.centerViewContainer];
    
    _centerViewController = centerViewController;
}

- (void)replaceViewController:(UIViewController *)sourceViewController withViewController:(UIViewController *)destinationViewController container:(UIView *)container {

    [sourceViewController willMoveToParentViewController:nil];
    [sourceViewController.view removeFromSuperview];
    [sourceViewController removeFromParentViewController];
    
    [self addChildViewController:destinationViewController];
    [container addSubview:destinationViewController.view];
   
    UIView *destinationView = destinationViewController.view;
    destinationView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(destinationView);
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[destinationView]|" options:0 metrics:nil views:views]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[destinationView]|" options:0 metrics:nil views:views]];

    [destinationViewController didMoveToParentViewController:self];
}

#pragma mark - Reveal Widths

- (void)setLeftDrawerRevealWidth:(CGFloat)leftDrawerRevealWidth {
    self.drawerView.leftViewContainerRevealWidth = leftDrawerRevealWidth;
}

- (void)setRightDrawerRevealWidth:(CGFloat)rightDrawerRevealWidth {
    self.drawerView.rightViewContainerRevealWidth = rightDrawerRevealWidth;
}

- (CGFloat)leftDrawerRevealWidth {
    return self.drawerView.leftViewContainerRevealWidth;
}

- (CGFloat)rightDrawerRevealWidth {
    return self.drawerView.rightViewContainerRevealWidth;
}

#pragma mark - Background Image

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.drawerView.backgroundImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage {
    return self.drawerView.backgroundImageView.image;
}

#pragma mark - Helpers

- (UIViewController *)viewControllerForDrawerSide:(JVFloatingDrawerSide)drawerSide {
    UIViewController *sideViewController = nil;
    switch (drawerSide) {
        case JVFloatingDrawerSideLeft: sideViewController = self.leftViewController; break;
        case JVFloatingDrawerSideRight: sideViewController = self.rightViewController; break;
        case JVFloatingDrawerSideNone: sideViewController = nil; break;
    }
    return sideViewController;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
