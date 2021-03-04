//
//  SCTipViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/25/21.
//

#import "SCTipViewController.h"
#import "SCIAPHelper.h"

static NSString *const kPreviousTips = @"previousTips";
static NSNotificationName const kNotificationName = @"IAPHelperFinishedNotification";

@interface SCTipViewController ()
@property (nonatomic) NSInteger previousTips;
@property (nonatomic) SCIAPHelper *store;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *previousTipLabel;

@end

@implementation SCTipViewController

- (instancetype)init {
    if (self == [super init]) {
        self.store = [SCIAPHelper new];
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewController];
    [self.store requestProductsWithCompletionHandler:^(BOOL success, NSArray<SKProduct*> *products) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleProductRequestWithSuccess:success andProducts:products];
        });
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kNotificationName
                                               object:nil];
}

- (void)configureViewController {
    self.title = @"Tip Jar";
    self.topButton.layer.cornerRadius = 10;
    self.middleButton.layer.cornerRadius = 10;
    self.bottomButton.layer.cornerRadius = 10;
    [self.contentView setHidden:YES];
    [self.activityIndicator startAnimating];
    [self updatePreviousTipLabel];
}

- (void)updatePreviousTipLabel {
    self.previousTips = [[NSUserDefaults standardUserDefaults] integerForKey:kPreviousTips] ?: 0;
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

- (void)handleProductRequestWithSuccess:(BOOL)success andProducts:(NSArray<SKProduct*> * _Nullable)products {
    if ([self.store canMakePayments] && success && [products count] == 3) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = products[0].priceLocale;
        [self.topButton setTitle:[formatter stringFromNumber:products[0].price] forState:UIControlStateNormal];
        [self.middleButton setTitle:[formatter stringFromNumber:products[1].price] forState:UIControlStateNormal];
        [self.bottomButton setTitle:[formatter stringFromNumber:products[2].price] forState:UIControlStateNormal];
        [self.contentView setHidden:NO];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error loading tip options from App Store."
                                                                       message:@"Please try again later!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Return to Settings"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [self.coordinator popViewControllerAnimated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self.activityIndicator stopAnimating];
}

- (void)setButtonsEnabled:(BOOL)enabled {
    [self.topButton setEnabled:enabled];
    [self.middleButton setEnabled:enabled];
    [self.bottomButton setEnabled:enabled];
}

- (void)handleNotification:(NSNotification*)notification {
    [self updatePreviousTipLabel];
    [self setButtonsEnabled:YES];
    [self.activityIndicator stopAnimating];
}

- (IBAction)topButtonPressed:(UIButton *)sender {
    [self.store buySmallTip];
    [self setButtonsEnabled:NO];
    [self.activityIndicator startAnimating];
}

- (IBAction)middleButtonPressed:(UIButton *)sender {
    [self.store buyMediumTip];
    [self setButtonsEnabled:NO];
    [self.activityIndicator startAnimating];
}

- (IBAction)bottomButtonPressed:(UIButton *)sender {
    [self.store buyLargeTip];
    [self setButtonsEnabled:NO];
    [self.activityIndicator startAnimating];
}



@end


