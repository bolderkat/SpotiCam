//
//  SCIAPHelper.m
//  SpotiCam
//
//  Created by Daniel Luo on 3/3/21.
//

#import "SCIAPHelper.h"

static NSString *const kPreviousTips = @"previousTips";
static NSString *const kSmallTip = @"SmallTip";
static NSString *const kMediumTip = @"MediumTip";
static NSString *const kLargeTip = @"LargeTip";
static NSNotificationName const kNotificationName = @"IAPHelperFinishedNotification";

@interface SCIAPHelper ()
@property (nonatomic) NSSet<ProductIdentifier*> *productIdentifiers;
@property (nonatomic) SKProductsRequest *productsRequest;
@property (nonatomic) ProductsRequestCompletionHandler productsRequestCompletionHandler;
@property (nonatomic) NSArray<SKProduct*> *products;

@end

@implementation SCIAPHelper

- (instancetype)init {
    self.productIdentifiers = [NSSet setWithObjects:kSmallTip, kMediumTip, kLargeTip, nil];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return self;
}

- (void)requestProductsWithCompletionHandler:(ProductsRequestCompletionHandler)completionHandler {
    if (self.productsRequest) {
        [self.productsRequest cancel];
    }
    
    self.productsRequestCompletionHandler = completionHandler;
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)buySmallTip {
    if ([self.products[0].productIdentifier isEqualToString:kSmallTip]) {
        NSLog(@"Buying %@", self.products[0]);
        SKPayment *payment = [SKPayment paymentWithProduct:self.products[0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)buyMediumTip {
    if ([self.products[1].productIdentifier isEqualToString:kMediumTip]) {
        NSLog(@"Buying %@", self.products[1]);
        SKPayment *payment = [SKPayment paymentWithProduct:self.products[1]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)buyLargeTip {
    if ([self.products[2].productIdentifier isEqualToString:kLargeTip]) {
        NSLog(@"Buying %@", self.products[2]);
        SKPayment *payment = [SKPayment paymentWithProduct:self.products[2]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (BOOL)canMakePayments {
    return SKPaymentQueue.canMakePayments;
}


#pragma mark:- SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    NSArray<SKProduct*> *products = response.products;
    self.products = [products sortedArrayUsingComparator:^NSComparisonResult(SKProduct*  _Nonnull obj1, SKProduct*  _Nonnull obj2) {
        return [obj1.price compare:obj2.price];
    }];
    
    self.productsRequestCompletionHandler(YES, self.products);
    [self clearRequestAndHandler];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    NSLog(@"Error: %@", [error localizedDescription]);
    self.productsRequestCompletionHandler(NO, nil);
    [self clearRequestAndHandler];
}

- (void)clearRequestAndHandler {
    self.productsRequest = nil;
    self.productsRequestCompletionHandler = nil;
}


#pragma mark:- SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        SKPaymentTransactionState state = transaction.transactionState;
        
        // Missing Swift switch statements right about now...
        if (state == SKPaymentTransactionStatePurchased) {
            [self completeWithTransaction:transaction];
        } else if (state == SKPaymentTransactionStateFailed) {
            [self failWithTransaction:transaction];
        }
    }
}

- (void)completeWithTransaction:(SKPaymentTransaction*)transaction {
    NSLog(@"Transaction complete!");
    NSInteger newTipCount = [[NSUserDefaults standardUserDefaults] integerForKey:kPreviousTips] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:newTipCount forKey:kPreviousTips];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self deliverFinishedNotificationWithIdentifier:transaction.payment.productIdentifier];
}

- (void)failWithTransaction:(SKPaymentTransaction*)transaction {
    NSLog(@"%@", [transaction.error localizedDescription]);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self deliverFinishedNotificationWithIdentifier:nil];
}

- (void)deliverFinishedNotificationWithIdentifier:(NSString*)identifier {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName object:identifier];
}
@end
