//
//  SCInfoViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 3/5/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCInfoViewController : UIViewController <Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;

@end

NS_ASSUME_NONNULL_END
