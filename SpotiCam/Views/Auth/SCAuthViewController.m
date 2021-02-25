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
    self.addAccountButton.layer.cornerRadius = 15;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)addButtonPressed:(UIButton *)sender {
    [self.coordinator.authManager doAuthWithAutoCodeExchange];
}

@end
