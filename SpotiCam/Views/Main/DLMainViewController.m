//
//  DLMainViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/9/21.
//

#import "DLMainViewController.h"

@interface DLMainViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic) UIImagePickerController *imagePicker;
@end

@implementation DLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


- (IBAction)takePictureTapped:(UIButton *)sender {
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (IBAction)chooseFromLibraryTapped:(UIButton *)sender {
    NSLog(@"Gray");
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self.imagePicker dismissViewControllerAnimated:NO completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self.coordinator goToProcessingViewWithImage:image];
}

@end
