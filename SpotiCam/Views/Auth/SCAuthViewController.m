//
//  SCAuthViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/16/21.
//

#import "SCAuthViewController.h"
#import "SCAuthManager.h"

@interface SCAuthViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addAccountButton;

@end

@implementation SCAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.addAccountButton.layer.cornerRadius = 15;
}

- (IBAction)addButtonPressed:(UIButton *)sender {
    [self.coordinator.authManager doAuthWithAutoCodeExchange];
}

@end
