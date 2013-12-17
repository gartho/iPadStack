//
//  CIPopdownNavigationController.m
//  CIPad
//

//

#import "CIPopdownNavigationController.h"
#import "CIPopdownRowViewController.h"
#import "UIViewController+CIPopdownNavigationController.h"
#import <QuartzCore/CAAnimation.h>

#define CIPopdownNavigationControllerStandardDistance ((float)64)
#define CIPopdownNavigationControllerStandardHeight ((float)400)
#define CIPopdownNavigationControllerSnappingVelocityThreshold ((float)100)

typedef enum {
    SnapNearest,
    SnapCompact,
    SnapRemove
} SnapMethod;

BOOL CGFloatEquals(CGFloat l, CGFloat r) {
    return abs(l-r) < 0.1;
}

BOOL CGFloatNotEqual(CGFloat l, CGFloat r) {
    return !CGFloatEquals(l, r);
}


@interface CIPopdownNavigationController (PrivateMethods)

- (void)attachGestureRecognizer;
- (void)detactGestureRecognizer;

@end

@implementation CIPopdownNavigationController

@synthesize panGesture;
@synthesize firstTouchedView;
@synthesize outOfBoundsViewController;
@synthesize viewControllers;

#pragma mark Initialization and Destroy

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    return [self initWithRootViewController:rootViewController configuration:^(CIPopdownNavigationItem *item) { }];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
                   configuration:(void (^)(CIPopdownNavigationItem *item))configuration {
    self = [super init];
    
    if (self) {
        CIPopdownRowViewController *popController = [[CIPopdownRowViewController alloc] initWithContentViewController:rootViewController maximumHeight:NO];
        
        viewControllers = [[NSMutableArray alloc] initWithObjects:popController, nil];
        popController.popdownNavigationItem.nextItemDistance = CIPopdownNavigationControllerStandardDistance;
        popController.popdownNavigationItem.height = CIPopdownNavigationControllerStandardHeight;
        configuration(popController.popdownNavigationItem);
        outOfBoundsViewController = nil;
        
        [self addChildViewController:popController];
        [popController didMoveToParentViewController:self];
    }
    return self;
}
#pragma mark - UIViewController interface

- (void)loadView {
    self.view = [[UIView alloc] init];
    
    for (CIPopdownRowViewController *vc in self.viewControllers) {
        vc.view.frame = CGRectMake(vc.popdownNavigationItem.currentViewPosition.x,
                                   vc.popdownNavigationItem.currentViewPosition.y,
                                   self.view.bounds.size.width,
                                   vc.popdownNavigationItem.height);
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:vc.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self attachGestureRecognizer];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"ORIENTATION, new size: %@", NSStringFromCGSize(self.view.bounds.size));
    [super didRotateFromInterfaceOrientation:orientation];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doLayout];
}

- (void)viewWillUnload
{
    [self detachGestureRecognizer];
    self.firstTouchedView = nil;
    self.outOfBoundsViewController = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"FRLayeredNavigationController (%@): viewDidUnload", self);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark Gesture Methods

- (void)attachGestureRecognizer {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.delegate = self;
    [self.view addGestureRecognizer:self.panGesture];
}

- (void)detachGestureRecognizer {
    [self.panGesture removeTarget:self action:NULL];
    self.panGesture.delegate = nil;
    self.panGesture = nil;
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
            //NSLog(@"UIGestureRecognizerStatePossible");
            break;
        }
            
        case UIGestureRecognizerStateBegan: {
            //NSLog(@"UIGestureRecognizerStateBegan");
            UIView *touchedView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view]
                                                        withEvent:nil];
            self.firstTouchedView = touchedView;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged, vel=%f", [gestureRecognizer velocityInView:firstView].x);
            
            const NSInteger startVcIdx = [self.viewControllers count]-1;
            const UIViewController *startVc = [self.viewControllers objectAtIndex:startVcIdx];
            
            [self moveViewControllersYTranslation:[gestureRecognizer translationInView:self.view].y];
            
            /*
             [self moveViewControllersStartIndex:startVcIdx
             xTranslation:[gestureRecognizer translationInView:self.view].x
             withParentIndex:-1
             parentLastPosition:CGPointZero
             descendentOfTouched:NO];
             */
            [gestureRecognizer setTranslation:CGPointZero inView:startVc.view];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            //NSLog(@"UIGestureRecognizerStateEnded");
            
            [UIView animateWithDuration:0.2 animations:^{
                [self moveToSnappingPointsWithGestureRecognizer:gestureRecognizer];
            }];
            
            self.firstTouchedView = nil;
            
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // TODO Insert any classes here we want to ignore...
    // if ([touch.view isKindOfClass:[UISlider class]]) {
        // prevent recognizing touches on the slider
    //     return NO;
    // }
    return YES;
}



#pragma mark Internal Methods

- (CGRect)getScreenBoundsForCurrentOrientation{
     UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return [CIPopdownNavigationController getScreenBoundsForOrientation:orientation];
}

+ (CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation {
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // Switch it round...
        CGRect temp;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    
    return fullScreenRect;
}

- (CGFloat)savePlaceWanted:(CGFloat)pointsWanted {
    CGFloat yTranslation = 0;
    NSLog(@"savePlaceWanted: %f", pointsWanted);
    if (pointsWanted <= 0) {
        return 0;
    }
    
    for (CIPopdownRowViewController *vc in self.viewControllers) {
        const CGFloat initY = vc.popdownNavigationItem.initialViewPosition.y;
        const CGFloat currentY = vc.popdownNavigationItem.currentViewPosition.y;
        
        if (initY < currentY + yTranslation) {
            yTranslation += initY - (currentY + yTranslation);
        }
        
        if (abs(yTranslation) >= pointsWanted) {
            break;
        }
    }
    
    for (CIPopdownRowViewController *vc in self.viewControllers) {
        if (vc == [self.viewControllers lastObject]) {
            break;
        }
        [CIPopdownNavigationController viewController:vc yTranslation:yTranslation bounded:YES];
    }
    return abs(yTranslation);
}

+ (BOOL)viewController:(CIPopdownRowViewController *)vc
          yTranslation:(CGFloat)origYTranslation
               bounded:(BOOL)bounded {
    BOOL didMoveOutOfBounds = NO;
    const CIPopdownNavigationItem *navItem = vc.popdownNavigationItem;
    const CGPoint initPos = navItem.initialViewPosition;
    
    if (bounded) {
        /* apply translation to fancy item position first and then apply to view */
        CGRect f = vc.view.frame;
        f.origin = navItem.currentViewPosition;
        f.origin.y += origYTranslation;
        
        if (f.origin.y <= initPos.y) {
            f.origin.y = initPos.y;
        }

        vc.view.frame = f;
        navItem.currentViewPosition = f.origin;
    
    } else {
        CGRect f = vc.view.frame;
        CGFloat yTranslation;
        if (f.origin.y < initPos.y && origYTranslation < 0) {
            yTranslation = origYTranslation / 2;
        } else {
            yTranslation = origYTranslation;
        }
        
        f.origin.y += yTranslation;
        
        /* apply translation to frame first */
        if (f.origin.y <= initPos.y) {
            didMoveOutOfBounds = YES;
            navItem.currentViewPosition = initPos;
        } else {
            navItem.currentViewPosition = f.origin;
        }
        vc.view.frame = f;
    }
    return didMoveOutOfBounds;
}

- (void)viewControllersToSnappingPointsMethod:(SnapMethod)method {
    CIPopdownRowViewController *last = nil;
    CGFloat yTranslation = 0;
    
    for (CIPopdownRowViewController *vc in self.viewControllers) {
    
        const CGPoint myPos = vc.popdownNavigationItem.currentViewPosition;
        const CGPoint myInitPos = vc.popdownNavigationItem.initialViewPosition;
       
        const CGFloat curDiff = myPos.y + last.popdownNavigationItem.currentViewPosition.y;
        const CGFloat initDiff = myInitPos.y + last.popdownNavigationItem.initialViewPosition.y;
         CGFloat maxDiff = last.view.bounds.size.height;
       // const CGFloat maxDiff = 200; // Fixme
        
        if (yTranslation == 0 && (CGFloatNotEqual(curDiff, initDiff) && CGFloatNotEqual(curDiff, maxDiff))) {
            switch (method) {
                case SnapNearest: {
                    NSLog(@"Snapping to nearest");
                    if ((curDiff - initDiff) > (maxDiff - curDiff)) {
                        // Bottom point is nearest
                        yTranslation = maxDiff - curDiff;
                    } else {
                        // Top point is nearest
                        yTranslation = initDiff - curDiff;
                    }
                    break;
                }
                case SnapCompact: {
                    NSLog(@"Snapping to compact");
                    yTranslation = initDiff - curDiff;
                    break;
                }
                case SnapRemove: {
                    // Fixme: Remove view controller
                    NSLog(@"Snapping to expand");
                    yTranslation = maxDiff - curDiff;
                    break;
                }
            }
        }
        NSLog(@"yTranslation %f", yTranslation);
        [CIPopdownNavigationController viewController:vc yTranslation:yTranslation bounded:YES];
        last = vc;
    }
}

- (void)moveToSnappingPointsWithGestureRecognizer:(UIPanGestureRecognizer *)g {
    const CGFloat velocity = [g velocityInView:self.view].y;
    SnapMethod method;
    
    if (abs(velocity) > CIPopdownNavigationControllerSnappingVelocityThreshold) {
        if (velocity > 0) {
            method = SnapRemove;
        } else {
            method = SnapCompact;
        }
    } else {
        method = SnapNearest;
    }
   
    [self viewControllersToSnappingPointsMethod:method];
}

- (void)moveViewControllersYTranslation:(CGFloat)yTranslationGesture {
    CIPopdownNavigationItem *parentNavItem = nil;
    CGPoint parentOldPos = CGPointZero;
    BOOL descendentOfTouched = NO;
    CIPopdownRowViewController *rootVC = [self.viewControllers objectAtIndex:0];
    
    for (CIPopdownRowViewController *me in [self.viewControllers reverseObjectEnumerator]) {
        if (rootVC == me) {
            break;
        }
        CIPopdownNavigationItem *meNavItem = me.popdownNavigationItem;
        
        const CGPoint myPos = meNavItem.currentViewPosition;
        const CGPoint myInitPos = meNavItem.initialViewPosition;
        const CGFloat myHeight = me.view.bounds.size.height;
        CGPoint myNewPos = myPos;
        
        const CGPoint myOldPos = myPos;
        const CGPoint parentPos = parentNavItem.currentViewPosition;
        const CGPoint parentInitPos = parentNavItem.initialViewPosition;
        
        CGFloat yTranslation = 0;
        
        if (parentNavItem == nil || !descendentOfTouched) {
            yTranslation = yTranslationGesture;
        } else {
            CGFloat newY = myPos.y;
            const CGFloat minDiff = parentInitPos.y - myInitPos.y;
            
            if (parentOldPos.y >= myPos.y + myHeight || parentPos.y >= myPos.y + myHeight) {
                // if snapped to parent's top border, move with parent
                newY = parentPos.y - myHeight;
            }
            
            if (parentPos.y - myNewPos.y <= minDiff) {
                // at least minDiff difference between parent and me
                newY = parentPos.y - minDiff;
            }
            
            yTranslation = newY - myPos.y;
        }
        
        const BOOL isTouchedView = !descendentOfTouched && [self.firstTouchedView isDescendantOfView:me.view];
        
        if (self.outOfBoundsViewController == nil ||
            self.outOfBoundsViewController == me ||
            yTranslationGesture < 0) {
            const BOOL boundedMove = !isTouchedView;
            
            const BOOL outOfBoundsMove = [CIPopdownNavigationController viewController:me
                                                                          yTranslation:yTranslation
                                                                               bounded:boundedMove];
            if (outOfBoundsMove) {
                self.outOfBoundsViewController = me;
            } else if(!outOfBoundsMove && self.outOfBoundsViewController == me) {
                self.outOfBoundsViewController = nil;
                [CIPopdownNavigationController viewControllerToInitialPosition:me];
                break;
            }
        }
        
        if (isTouchedView) {
            NSAssert(!descendentOfTouched, @"cannot be descendent of touched AND touched view");
            descendentOfTouched = YES;
        }
        
        /* initialize next iteration */
        parentNavItem = meNavItem;
        parentOldPos = myOldPos;
    }
}

+ (void)viewControllerToInitialPosition:(CIPopdownRowViewController *)vc {
    const CGPoint initPos = vc.popdownNavigationItem.initialViewPosition;
    CGRect f = vc.view.frame;
    f.origin = initPos;
    vc.popdownNavigationItem.currentViewPosition = initPos;
    vc.view.frame = f;
}



- (void)doLayout {
    for (CIPopdownRowViewController *vc in self.viewControllers) {
        CGRect f = vc.view.frame;
        if (vc.popdownNavigationItem.currentViewPosition.y < vc.popdownNavigationItem.initialViewPosition.y) {
            vc.popdownNavigationItem.currentViewPosition = vc.popdownNavigationItem.initialViewPosition;
        }
        f.origin = vc.popdownNavigationItem.currentViewPosition;
        
        if (vc.maximumHeight) {
            f.size.height = self.view.bounds.size.height - vc.popdownNavigationItem.initialViewPosition.y;
            vc.popdownNavigationItem.height = f.size.height;
        }
        
        f.size.height = self.view.bounds.size.height;
        
        vc.view.frame = f;
    }
}


#pragma mark Instance Methods

- (void)popViewControllerAnimated:(BOOL)animated {
    UIViewController *controller = [self.viewControllers lastObject];
    
    // Don't return the root controller
    if ([self.viewControllers count] == 1) {
        return;
    }
    
    [controller willMoveToParentViewController:nil];
    [self.viewControllers removeObject:controller];
    
    CGRect removeFrame = CGRectMake(controller.view.frame.origin.x, 1024, controller.view.bounds.size.width, controller.view.bounds.size.height);
    // Animate and remove the controller
    [UIView animateWithDuration:animated ? 0.5 : 0
                          delay:0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         controller.view.frame = removeFrame;
                     }
                     completion:^(BOOL finished) {
                         [controller.view removeFromSuperview];
                         [controller removeFromParentViewController];
                     }];
}

- (void)popToViewController:(UIViewController *)vc animated:(BOOL)animated {
    UIViewController *currentVc;
    
    // Loop through all the controllers and remove them until we match the parameter
    while ((currentVc = [self.viewControllers lastObject])) {
        
        if (([currentVc class] == [CIPopdownRowViewController class] &&
             ((CIPopdownRowViewController*)currentVc).contentViewController == vc) ||
            ([currentVc class] != [CIPopdownRowViewController class] &&
             currentVc == vc)) {
                break;
            }
        
        // Don't return the root view controller
        if ([self.viewControllers count] == 1) {
            return;
        }
        
        [self popViewControllerAnimated:animated];
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated {
    [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

- (void)pushViewController:(UIViewController *)contentViewController
                  behindOf:(UIViewController *)anchorViewController
             maximumHeight:(BOOL)maxHeight
                  animated:(BOOL)animated
             configuration:(void (^)(CIPopdownNavigationItem *item))configuration {
    
    CIPopdownRowViewController *newVC = [[CIPopdownRowViewController alloc]
                                initWithContentViewController:contentViewController
                                                maximumHeight:maxHeight];
    
    const CIPopdownNavigationItem *navItem = newVC.popdownNavigationItem;
    // Need protected Implementation?
    const CIPopdownNavigationItem *parentNavItem = anchorViewController.popdownNavigationItem;
    
    const CGFloat overallHeight = self.view.bounds.size.height > 0 ?
        self.view.bounds.size.height :
        [self getScreenBoundsForCurrentOrientation].size.height;
    
    [self popToViewController:anchorViewController animated:animated];
    
    CGFloat anchorInitY = anchorViewController.popdownNavigationItem.initialViewPosition.y;
    CGFloat anchorCurrentY = anchorViewController.popdownNavigationItem.currentViewPosition.y;
    CGFloat anchorHeight = anchorViewController.popdownNavigationItem.height;
    CGFloat initY = anchorInitY + (parentNavItem.nextItemDistance > 0 ?
                                   parentNavItem.nextItemDistance :
                                   CIPopdownNavigationControllerStandardDistance);
    navItem.initialViewPosition = CGPointMake(0, initY);
    navItem.currentViewPosition = CGPointMake(0, anchorCurrentY + anchorHeight);
    
    configuration(newVC.popdownNavigationItem);
    
    CGFloat height;
    if (navItem.height > 0) {
        height = navItem.height;
    } else {
        height = newVC.maximumHeight ? overallHeight - initY : CIPopdownNavigationControllerStandardHeight;
        navItem.height = height;
    }
    
    CGRect onscreenFrame = CGRectMake(newVC.popdownNavigationItem.currentViewPosition.x,
                                      newVC.popdownNavigationItem.currentViewPosition.y,
                                      self.view.bounds.size.width,
                                      height);
        
    CGRect offscreenFrame = CGRectMake(newVC.popdownNavigationItem.currentViewPosition.x,
                                      newVC.popdownNavigationItem.currentViewPosition.y - 200, // TODO const.
                                      self.view.bounds.size.width,
                                      height);
    
    newVC.view.frame = offscreenFrame;
    
    [self.viewControllers addObject:newVC];
    [self addChildViewController:newVC];
    [self.view addSubview:newVC.view];
    
    [newVC didMoveToParentViewController:self];

    
    [UIView animateWithDuration:animated ? 0.4 : 0
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGFloat saved = [self savePlaceWanted:onscreenFrame.origin.y + height - overallHeight];
                         newVC.view.frame = CGRectMake(onscreenFrame.origin.x,
                                                       onscreenFrame.origin.y - saved,
                                                       onscreenFrame.size.width,
                                                       onscreenFrame.size.height);
                         newVC.popdownNavigationItem.currentViewPosition = newVC.view.frame.origin;
                         
                     }
                     completion:^(BOOL finished) {
//                         CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.y"];
//                         bounce.duration = 0.05;
//                         bounce.fromValue = [NSNumber numberWithInt:newVC.popdownNavigationItem.currentViewPosition.y + 100];
//                         bounce.toValue = [NSNumber numberWithInt:newVC.popdownNavigationItem.currentViewPosition.y + 103];
//                         bounce.repeatCount = 1;
//                         bounce.autoreverses = YES;
//                         
//                         bounce.removedOnCompletion = NO;
//                         [newVC.view.layer addAnimation:bounce forKey:@"bounce"];
                     }];
}

- (void)pushViewController:(UIViewController *)contentViewController
                  behindOf:(UIViewController *)anchorViewController
             maximumHeight:(BOOL)maxHeight
                  animated:(BOOL)animated {
    [self pushViewController:contentViewController
                    behindOf:anchorViewController
               maximumHeight:maxHeight
                    animated:animated
               configuration:^(CIPopdownNavigationItem *item) {
               }];
}



@end
