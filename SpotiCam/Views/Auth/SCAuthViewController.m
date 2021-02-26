//
//  SCAuthViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/16/21.
//

#import "SCAuthViewController.h"
#import "SCAuthManager.h"
#import "SCPrivacyViewController.h"

@interface SCAuthViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addAccountButton;

@end

@implementation SCAuthViewController

// TODO: Adjust header font size and constraint value for iPod Touch size class.

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addAccountButton.layer.cornerRadius = 15;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)addButtonPressed:(UIButton *)sender {
    [self.coordinator.authManager doAuthWithAutoCodeExchange];
}

- (IBAction)privacyPolicyPressed:(UIButton *)sender {
    SCPrivacyViewController *vc = [SCPrivacyViewController new];
    [self presentViewController:vc animated:YES completion:nil];
    [vc setAppearanceForAuthScreen];
}

@end
