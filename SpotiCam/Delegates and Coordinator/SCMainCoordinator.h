//
//  SCMainCoordinator.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SCAuthManager.h"

@class SCAPIManager;

NS_ASSUME_NONNULL_BEGIN


@interface SCMainCoordinator : NSObject
@property UIWindow *window;
@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) SCAuthManager *authManager;

- (instancetype)initWithWindow:(UIWindow*)window;
- (void)start;
- (void)proceedAfterAuth;
- (void)dismissGenresView;
- (void)goToSettingsView;
- (void)goToProcessingViewWithImage:(UIImage*)image;
- (void)goToRecommendationsViewWithAPIManager:(SCAPIManager*)apiManager;
- (void)openGenresFromSettings;
- (void)openTipJar;
- (void)logOut;

@end

@protocol Coordinated
@required
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@end
NS_ASSUME_NONNULL_END
