//
//  CIPopdownNavigationController.h
//  CIPad
//
//  Created by Garth Oatley on 27/07/2012.
//  Copyright (c) 2012 SAS Institute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIPopdownNavigationItem.h"

@interface CIPopdownNavigationController : UIViewController<UIGestureRecognizerDelegate> {
    UIView * __weak firstTouchedView;
    NSMutableArray * viewControllers;
    UIPanGestureRecognizer * panGesture;
    UIViewController * __weak outOfBoundsViewController;
}

@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, readwrite, strong) NSMutableArray *viewControllers;
@property (nonatomic, readwrite, weak) UIViewController *outOfBoundsViewController;
@property (nonatomic, readwrite, weak) UIView *firstTouchedView;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (id)initWithRootViewController:(UIViewController *)rootViewController
                   configuration:(void (^)(CIPopdownNavigationItem *item))configuration;

- (void)popViewControllerAnimated:(BOOL)animated;

- (void)popToRootViewControllerAnimated:(BOOL)animated;

- (void)popToViewController:(UIViewController *)vc animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController
                 behindOf:(UIViewController *)anchorViewController
             maximumHeight:(BOOL)maxHeight
                  animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController
                 behindOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(CIPopdownNavigationItem *item))configuration;

@end