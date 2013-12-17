//
//  CIPopdownRowControllerViewController.h
//  CIPad
//
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