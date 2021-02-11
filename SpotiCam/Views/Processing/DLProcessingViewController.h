//
//  DLProcessingViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import <UIKit/UIKit.h>
#import "DLMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface DLProcessingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) DLMainCoordinator *coordinator;
@property UIImage *image;

@end

NS_ASSUME_NONNULL_END
