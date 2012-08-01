//
//  UIViewController+CIPopdownNavigationController.h
//  CIPad
//
//  Created by Garth on 30/07/2012.
//  Copyright (c) 2012 SAS Institute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIPopdownNavigationController.h"
#import "CIPopdownNavigationItem.h"

@interface UIViewController (CIPopdownNavigationController)

@property (nonatomic, readonly, strong) CIPopdownNavigationController *popdownNavigationController;
@property (nonatomic, readonly, strong) CIPopdownNavigationItem *popdownNavigationItem;

@end
