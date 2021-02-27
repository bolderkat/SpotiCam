//
//  SCMainViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/9/21.
//

#import "SCMainViewController.h"

@interface SCMainViewController () 
@property (nonatomic) UIImagePickerController *imagePicker;
@end

@implementation SCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
}

- (IBAction)takePictureTapped:(UIButton *)sender {
    [self.coordinator goToCameraView];
}

- (IBAction)chooseFromLibraryTapped:(UIButton *)sender {
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (IBAction)settingsButtonTapped:(UIButton *)sender {
    [self.coordinator goToSettingsView];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self.imagePicker dismissViewControllerAnimated:NO completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self.coordinator goToProcessingViewWithImage:image];
}

@end
