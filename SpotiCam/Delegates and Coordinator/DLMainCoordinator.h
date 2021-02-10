//
//  DLMainCoordinator.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DLMainCoordinator : NSObject
@property UIWindow *window;
@property UINavigationController *navigationController;
- (instancetype)initWithWindow:(UIWindow*)window;
- (void)start;

@end

NS_ASSUME_NONNULL_END
