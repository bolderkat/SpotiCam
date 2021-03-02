//
//  SCGenresViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/17/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCGenresViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;

@end

NS_ASSUME_NONNULL_END
