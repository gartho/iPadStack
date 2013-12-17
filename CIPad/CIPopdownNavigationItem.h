//
//  CIPopdownNavigationItem.h
//  CIPad
//

//

#import <Foundation/Foundation.h>
#import "CIPopdownRowViewController.h"

@interface CIPopdownNavigationItem : NSObject {
    CGPoint initialViewPosition;
    CGPoint currentViewPosition;
    CGFloat height;
    CGFloat nextItemDistance;
    CIPopdownRowViewController __weak * popdownController;
}

@property (nonatomic, readwrite) CGPoint initialViewPosition;
@property (nonatomic, readwrite) CGPoint currentViewPosition;
@property (nonatomic, readwrite) CGFloat height;
@property (nonatomic, readwrite) CGFloat nextItemDistance;
@property (nonatomic, readwrite, weak) CIPopdownRowViewController *popdownController;

@end
