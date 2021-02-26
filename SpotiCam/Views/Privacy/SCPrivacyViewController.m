//
//  SCPrivacyViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/25/21.
//

#import "SCPrivacyViewController.h"

@interface SCPrivacyViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *bodyTextLabel;
@end

@implementation SCPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Privacy Policy";
}

- (void)setAppearanceForAuthScreen {
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.contentView.backgroundColor = [UIColor darkGrayColor];
    self.bodyTextLabel.textColor = [UIColor whiteColor];
}

@end
