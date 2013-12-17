//
//  UIViewController+CIPopdownNavigationController.h
//  CIPad
//

#import <UIKit/UIKit.h>
#import "CIPopdownNavigationController.h"
#import "CIPopdownNavigationItem.h"

@interface UIViewController (CIPopdownNavigationController)

@property (nonatomic, readonly, strong) CIPopdownNavigationController *popdownNavigationController;
@property (nonatomic, readonly, strong) CIPopdownNavigationItem *popdownNavigationItem;

@end
