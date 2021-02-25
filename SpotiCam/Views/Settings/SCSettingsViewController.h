//
//  SCSettingsViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCSettingsViewController : UIViewController <UITableViewDelegate, Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;

@end

NS_ASSUME_NONNULL_END
