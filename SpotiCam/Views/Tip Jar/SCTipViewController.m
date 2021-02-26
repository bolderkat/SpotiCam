//
//  SCTipViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/25/21.
//

#import "SCTipViewController.h"

static NSString *const kPreviousTips = @"previousTips";

@interface SCTipViewController ()
@property (nonatomic) NSInteger previousTips;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *previousTipLabel;

@end

@implementation SCTipViewController

- (instancetype)init {
    if (self == [super init]) {
        self.previousTips = [[NSUserDefaults standardUserDefaults] integerForKey:kPreviousTips] ?: 0;
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewController];
}

- (void)configureViewController {
    self.title = @"Tip Jar";
    self.topButton.layer.cornerRadius = 10;
    self.middleButton.layer.cornerRadius = 10;
    self.bottomButton.layer.cornerRadius = 10;
    [self updatePreviousTipLabel];
}

- (void)updatePreviousTipLabel {
    switch (self.previousTips) {
        case 0:
            self.previousTipLabel.text = nil;
            break;
        case 1:
            self.previousTipLabel.text = [NSString stringWithFormat:@"You have tipped %ld time before. You rock!", self.previousTips];
            break;
        default:
            self.previousTipLabel.text = [NSString stringWithFormat:@"You have tipped %ld times before. You rock!", self.previousTips];
            break;
    }
}
- (IBAction)topButtonPressed:(UIButton *)sender {
    
}

- (IBAction)middleButtonPressed:(UIButton *)sender {

}

- (IBAction)bottomButtonPressed:(UIButton *)sender {

}



@end


