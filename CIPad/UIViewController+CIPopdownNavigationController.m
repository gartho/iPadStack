//
//  UIViewController+CIPopdownNavigationController.m
//  CIPad
//
//

#import "UIViewController+CIPopdownNavigationController.h"
#import "CIPopdownRowViewController.h"

@implementation UIViewController (CIPopdownNavigationController)

- (CIPopdownNavigationController *)popdownNavigationController {
    UIViewController *here = self;
    
    while (here != nil) {
        if([here class] == [CIPopdownNavigationController class]) {
            return (CIPopdownNavigationController *)here;
        }
        
        here = here.parentViewController;
    }
    
    NSLog(@"HINT: If you used [UIWindow addSubview:], change it to [UIWindow setRootViewController:]");
    
    return nil;
}

- (CIPopdownNavigationItem *)popdownNavigationItem {
    UIViewController *here = self;
    
    while (here != nil) {
        if([here class] == [CIPopdownRowViewController class]) {
            return ((CIPopdownRowViewController *)here).popdownNavigationItem;
        }
        
        here = here.parentViewController;
    }
    
    NSLog(@"HINT: The popdownNavigationItem property is nil until the view controller is shown on the screen.");
    
    return nil;
}


@end
