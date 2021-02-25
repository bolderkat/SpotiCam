//
//  SCMainViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/9/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

@interface SCMainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;

@end

