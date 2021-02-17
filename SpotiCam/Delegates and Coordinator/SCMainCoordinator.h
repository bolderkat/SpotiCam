//
//  SCMainCoordinator.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SCAuthManager.h"

NS_ASSUME_NONNULL_BEGIN


@interface SCMainCoordinator : NSObject
@property UIWindow *window;
@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) SCAuthManager *authManager;

- (instancetype)initWithWindow:(UIWindow*)window;
- (void)start;
- (void)proceedAfterAuth;
- (void)goToProcessingViewWithImage:(UIImage*)image;

@end

@protocol Coordinated
@required
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@end
NS_ASSUME_NONNULL_END
