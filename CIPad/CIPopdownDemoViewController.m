//
//  CIPopdownDemoViewController.m
//  CIPad
//
//  Created by Garth on 02/08/2012.
//  Copyright (c) 2012 SAS Institute. All rights reserved.
//

#import "CIPopdownDemoViewController.h"

#import "CIPopdownNavigationController.h"
#import "CIPopdownNavigationItem.h"
#import "UIViewController+CIPopdownNavigationController.h"


@interface CIPopdownDemoViewController () {
    UIButton *popToRoot;
    UIButton *popViewController;
    UIButton *pushNewViewController;
}
- (UIButton *)bigButton;
@end

@implementation CIPopdownDemoViewController

- (UIButton *)bigButton {
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleEdgeInsets = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
	return button;
}

- (void)popToRoot:(id)sender {
    [self.popdownNavigationController popToRootViewControllerAnimated:YES];
}

-(void)pushNewController:(id)sender {
    UIViewController *svc = [[CIPopdownDemoViewController alloc] init];
    
    [self.popdownNavigationController pushViewController:svc behindOf:self maximumHeight:NO animated:YES configuration:^(CIPopdownNavigationItem *item) {
        item.height = 200;
        item.nextItemDistance = 64;
        
        return;
    }];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    float r = arc4random() % 12;
	self.view.backgroundColor = [UIColor colorWithHue:(30*r)/360 saturation:0.5f brightness:0.8f alpha:1.0f];
    popToRoot = [self bigButton];
	popToRoot.frame = CGRectMake(50, 50, 100, 100);
	popToRoot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[popToRoot setTitle:@"Pop to Root" forState:UIControlStateNormal];
	[popToRoot addTarget:self action:@selector(popToRoot:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:popToRoot];

    pushNewViewController = [self bigButton];
	pushNewViewController.frame = CGRectMake(200, 50, 100, 100);
	pushNewViewController.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[pushNewViewController setTitle:@"Push New" forState:UIControlStateNormal];
	[pushNewViewController addTarget:self action:@selector(pushNewController:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:pushNewViewController];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
