//
//  CICampaignDetailViewController.m
//  CIPad
//
//

#import "CICampaignDetailViewController.h"
#import "UIFont+CIPadAdditions.h"

@interface CICampaignDetailViewController ()

@end

@implementation CICampaignDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    float r = arc4random() % 12;
	self.view.backgroundColor = [UIColor colorWithHue:(30*r)/360 saturation:0.5f brightness:0.8f alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 230.0f, 280.0f, 60.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.text = @"Banking Cross Sell Campaign";
    label.font = [UIFont boldCIPadFontOfSize:22.0f];
    [self.view addSubview:label];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
