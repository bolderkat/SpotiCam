//
//  SCPrivacyViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/25/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCPrivacyViewController : UIViewController <Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;

- (void)setAppearanceForAuthScreen;

@end

NS_ASSUME_NONNULL_END
