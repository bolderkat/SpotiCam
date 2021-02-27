//
//  SCProcessingViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCProcessingViewController : UIViewController <UIGestureRecognizerDelegate, Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@property UIImage *image;

@end

NS_ASSUME_NONNULL_END
