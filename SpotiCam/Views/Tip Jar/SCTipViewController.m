//
//  SCTipViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/25/21.
//

#import "SCTipViewController.h"


static NSString *const kPreviousTips = @"previousTips";
static NSNotificationName const kNotificationName = @"IAPHelperFinishedNotification";

@interface SCTipViewController ()
@property (nonatomic) NSInteger previousTips;
@property (nonatomic) SCIAPHelper *store;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tipLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *tipLoadingLabel;
@property (weak, nonatomic) IBOutlet UIView *transactionLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *transactionLoadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *transactionActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *previousTipLabel;

@end

@implementation SCTipViewController

- (instancetype)initWithStore:(SCIAPHelper*)store {
    if (self == [super init]) {
        self.store = store;
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
    self.transactionLoadingView.layer.cornerRadius = 15;
    [self setTransactionLoadingViewHidden:YES];
    [self.stackView setHidden:YES];
    [self.tipLoadingIndicator startAnimating];
    [self.tipLoadingLabel setHidden:NO];
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

- (void)setTransactionLoadingViewHidden:(BOOL)hidden {
    [self.transactionLoadingView setHidden:hidden];
    [self.transactionLoadingLabel setHidden:hidden];
    [self.transactionActivityIndicator setHidden:hidden];
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
        [self.stackView setHidden:NO];
    } else if (![self.store canMakePayments]) {
        [self displayPaymentsNotAllowedError];
    } else {
        [self displayTipLoadingError];
    }
    [self.tipLoadingIndicator stopAnimating];
    [self.tipLoadingLabel setHidden:YES];
}

- (void)displayPaymentsNotAllowedError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Payments are not allowed for this user"
                                                                   message:@"This may be related to your Apple ID/App Store account settings or parental controls."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)displayTipLoadingError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to load tip options from App Store"
                                                                   message:@"Please try again later!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setButtonsEnabled:(BOOL)enabled {
    [self.topButton setEnabled:enabled];
    [self.middleButton setEnabled:enabled];
    [self.bottomButton setEnabled:enabled];
}

- (void)handleNotification:(NSNotification*)notification {
    [self updatePreviousTipLabel];
    [self setButtonsEnabled:YES];
    [self setTransactionLoadingViewHidden:YES];
}

- (IBAction)topButtonPressed:(UIButton *)sender {
    [self.store buySmallTip];
    [self setButtonsEnabled:NO];
    [self setTransactionLoadingViewHidden:NO];
}

- (IBAction)middleButtonPressed:(UIButton *)sender {
    [self.store buyMediumTip];
    [self setButtonsEnabled:NO];
    [self setTransactionLoadingViewHidden:NO];
}

- (IBAction)bottomButtonPressed:(UIButton *)sender {
    [self.store buyLargeTip];
    [self setButtonsEnabled:NO];
    [self setTransactionLoadingViewHidden:NO];
}



@end


