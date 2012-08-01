//
//  CIPopdownRowControllerViewController.h
//  CIPad
//
//  Created by Garth on 28/07/2012.
//  Copyright (c) 2012 SAS Institute. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CIPopdownNavigationItem;

@interface CIPopdownRowViewController : UIViewController {
    CIPopdownNavigationItem *popdownNavigationItem;
    BOOL maximumHeight;
    UIView *borderView;
    UIViewController *contentViewController;
}

- (id)initWithContentViewController:(UIViewController *)vc maximumHeight:(BOOL)maxHeight;

@property (nonatomic, readwrite, strong) CIPopdownNavigationItem *popdownNavigationItem;
@property (nonatomic, readwrite, strong) UIViewController *contentViewController;
@property (nonatomic, readwrite) BOOL maximumHeight;
@property (nonatomic, readwrite, strong) UIView *borderView;

@end