//
//  CIPopdownRowControllerViewController.m
//  CIPad
//
//

#import "CIPopdownRowViewController.h"
#import "CIPopdownNavigationItem.h"
#import <QuartzCore/QuartzCore.h>


@implementation CIPopdownRowViewController

@synthesize contentViewController;
@synthesize maximumHeight;
@synthesize borderView;
@synthesize popdownNavigationItem;


#pragma mark - init/dealloc

- (id)initWithContentViewController:(UIViewController *)vc maximumHeight:(BOOL)maxHeight {
    if ((self = [super init])) {
        self.popdownNavigationItem = [[CIPopdownNavigationItem alloc] init];
        self.popdownNavigationItem.popdownController = self;
        self.contentViewController = vc;
        self.maximumHeight = maxHeight;
        
        [self attachContentViewController];
    }
    
    return self;
}

- (void)dealloc {
    self.popdownNavigationItem.popdownController = nil;
    [self detachContentViewController];
}

#pragma mark - internal methods

- (void)doViewLayout {
    CGRect contentFrame = CGRectMake(0,
                                     0,
                                     self.view.bounds.size.width,
                                     self.popdownNavigationItem.height);
    
    self.contentViewController.view.frame = contentFrame;
}

- (void)attachContentViewController {
    [self addChildViewController:self.contentViewController];
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)detachContentViewController {
    [self.contentViewController willMoveToParentViewController:nil];
    [self.contentViewController removeFromParentViewController];
}

#pragma mark - UIViewController interface methods

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentViewController.view];
}

- (void)viewWillLayoutSubviews {
    // Lazy add shadow
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowOffset = CGSizeMake(2.0, 3.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    [self doViewLayout];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.borderView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end

