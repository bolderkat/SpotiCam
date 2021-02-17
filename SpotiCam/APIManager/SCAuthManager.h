//
//  SCAuthManager.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/16/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OIDAuthState;
@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface SCAuthManager : NSObject

@property(nonatomic, readonly, nullable) OIDAuthState *authState;
@property(weak, nonatomic) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END
