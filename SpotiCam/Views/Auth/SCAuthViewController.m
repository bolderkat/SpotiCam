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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation SCAuthViewController

// TODO: Adjust header font size and constraint value for iPod Touch size class.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureForSizeClass];
    self.addAccountButton.layer.cornerRadius = 15;
}

- (void)configureForSizeClass {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat iPhone8Height = 667.0;
    CGFloat iPhoneXHeight = 812.0;
    CGFloat iPhone12Height = 844.0;
    
    if (screenHeight < iPhone8Height) {
        self.headerTopConstraint.constant = 140;
        self.headerLabel.adjustsFontSizeToFitWidth = YES;
    } else if (screenHeight >= iPhoneXHeight && screenHeight <= iPhone12Height) {
        self.headerTopConstraint.constant = 240;
    } else if (screenHeight > iPhone12Height) {
        self.headerTopConstraint.constant = 320;
    } else {
        self.headerTopConstraint.constant = 200;
    }
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
