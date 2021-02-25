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
@class SCMainCoordinator;

NS_ASSUME_NONNULL_BEGIN

@interface SCAuthManager : NSObject

@property(nonatomic, readonly, nullable) OIDAuthState *authState;
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@property(nonatomic, weak, nullable) UIViewController *viewController;

- (void)loadState;
- (void)setAuthState:(OIDAuthState * _Nullable)authState;
- (void)doAuthWithAutoCodeExchange;

@end

NS_ASSUME_NONNULL_END
