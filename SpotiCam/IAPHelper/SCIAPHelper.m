//
//  SCIAPHelper.m
//  SpotiCam
//
//  Created by Daniel Luo on 3/3/21.
//

#import "SCIAPHelper.h"


@interface SCIAPHelper ()
@property (nonatomic) NSSet<ProductIdentifier*> *productIdentifiers;
@property (nonatomic) SKProductsRequest *productsRequest;
@property (nonatomic) ProductsRequestCompletionHandler productsRequestCompletionHandler;

@end

@implementation SCIAPHelper

- (instancetype)init {
    self.productIdentifiers = [NSSet setWithObjects:@"SmallTip", @"MediumTip", @"LargeTip", nil];
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

- (BOOL)canMakePayments {
    return SKPaymentQueue.canMakePayments;
}


#pragma mark:- SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    NSArray<SKProduct*> *products = response.products;
    self.productsRequestCompletionHandler(YES, products);
    [self clearRequestAndHandler];
    
    for (SKProduct *product in products) {
        NSLog(@"Found product: %@ %@ %.2f", product.productIdentifier, product.localizedTitle, product.price.floatValue);
    }
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

@end
