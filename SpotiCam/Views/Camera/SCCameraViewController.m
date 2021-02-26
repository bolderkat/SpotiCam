//
//  SCCameraViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/26/21.
//

#import "SCCameraViewController.h"

@interface SCCameraViewController ()
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation SCCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUpCaptureSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

- (void)configureViewController {
    self.takePhotoButton.layer.cornerRadius = 40;
    self.backButton.layer.cornerRadius = 20;
}

- (void)setUpCaptureSession {
    // Adapted from https://guides.codepath.com/ios/Creating-a-Custom-Camera-View
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        NSLog(@"** CameraVC ** Unable to access back camera!");
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera
                                                                        error:&error];
    if (error) {
        NSLog(@"** CameraVC ** Unable to initialize back camera: %@", [error localizedDescription]);
        return;
    }
    
    self.stillImageOutput = [AVCapturePhotoOutput new];
    
    if ([self.captureSession canAddInput:input] && [self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addInput:input];
        [self.captureSession addOutput:self.stillImageOutput];
        [self setUpLivePreview];
    }
}

- (void)setUpLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.previewView.layer addSublayer:self.videoPreviewLayer];
        
        __weak typeof(self) weakSelf = self;
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [weakSelf.captureSession startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.videoPreviewLayer.frame = weakSelf.previewView.bounds;
            });
        });
    }
}
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.coordinator popViewControllerAnimated:YES];
}

- (IBAction)didTakePhoto:(UIButton *)sender {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeHEVC}];
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    NSData *imageData = photo.fileDataRepresentation;
    if (imageData) {
        [self.coordinator goToProcessingViewWithImage:[UIImage imageWithData:imageData]];
    }
}

@end
