//
//  SCIAPHelper.h
//  SpotiCam
//
//  Created by Daniel Luo on 3/3/21.
//

// Translated to Objective-C from tutorial: https://www.raywenderlich.com/5456-in-app-purchase-tutorial-getting-started

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString ProductIdentifier;
typedef void (^ProductsRequestCompletionHandler)(BOOL, NSArray<SKProduct*>* _Nullable);

@interface SCIAPHelper : NSObject <SKProductsRequestDelegate>
- (void)requestProductsWithCompletionHandler:(ProductsRequestCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
