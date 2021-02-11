//
//  SCMainCoordinator.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCMainCoordinator : NSObject
@property UIWindow *window;
@property UINavigationController *navigationController;
- (instancetype)initWithWindow:(UIWindow*)window;
- (void)start;
- (void)goToProcessingViewWithImage:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
