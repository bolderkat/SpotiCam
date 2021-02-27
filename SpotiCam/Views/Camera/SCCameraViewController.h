//
//  SCCameraViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/26/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCCameraViewController : UIViewController <UIGestureRecognizerDelegate, AVCapturePhotoCaptureDelegate, Coordinated>
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@property (nonatomic, nullable) AVCaptureSession *captureSession;
@property (nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

NS_ASSUME_NONNULL_END
