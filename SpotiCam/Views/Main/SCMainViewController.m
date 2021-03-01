//
//  SCMainViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/9/21.
//

#import "SCMainViewController.h"

@interface SCMainViewController () 
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@end

@implementation SCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setButtonsEnabled:YES];
    [self.selectedImageView setImage:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
}

- (void)setButtonsEnabled:(BOOL)enabled {
    [self.topButton setEnabled:enabled];
    [self.bottomButton setEnabled:enabled];
    [self.settingsButton setEnabled:enabled];
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
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.selectedImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.selectedImageView setImage:image];
    [self setButtonsEnabled:NO];
    __weak typeof(self) weakSelf = self;
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.coordinator performSelector:@selector(goToProcessingViewWithImage:) withObject:image afterDelay:0.5];
    }];
}

@end
