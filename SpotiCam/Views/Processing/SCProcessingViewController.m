//
//  SCProcessingViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import "SCProcessingViewController.h"
#import "SCAPIManager.h"

@interface SCProcessingViewController ()
@property (nonatomic) SCAPIManager *apiManager;
@property (nonatomic) UIColor *dominantColor;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *getTracksBackgroundView;

@end

@implementation SCProcessingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dominantColor = [self getDominantColorFromPhoto];
    [self configureViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

- (void)configureViewController {
    self.colorView.backgroundColor = self.dominantColor;
    [self calculateTrackAttributesFromColor:self.dominantColor];
    self.getTracksBackgroundView.layer.cornerRadius = 15;
}

- (UIColor*)getDominantColorFromPhoto {
    // Adapted from https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    CIImage *image = [CIImage imageWithCGImage:self.image.CGImage];
    CGFloat width = image.extent.size.width;
    CGFloat height = image.extent.size.height;
    
    // Use central area of photo only for averaging
    CIVector *extentVector = [CIVector vectorWithX:image.extent.origin.x + width / 4 Y:image.extent.origin.y + height / 4 Z:width / 2 W:height / 2];
    CIFilter *filter = [CIFilter filterWithName:@"CIAreaAverage" withInputParameters:@{kCIInputImageKey: image, kCIInputExtentKey: extentVector}];
    CIImage *outputImage = [filter outputImage];
    
    uint8_t bitmap[4];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: [NSNull null]}];
    [context render:outputImage toBitmap:bitmap rowBytes:4 bounds:CGRectMake(0, 0, 1, 1) format:kCIFormatRGBA8 colorSpace:nil];
    
    UIColor *averageColor = [UIColor colorWithRed:(CGFloat)bitmap[0] / 255 green:(CGFloat)bitmap[1] / 255 blue:(CGFloat)bitmap[2] / 255 alpha:(CGFloat)bitmap[3] / 255];
    
    // Increase saturation of color to get dominant color from average
    CGFloat h, s, b, a;
    [averageColor getHue:&h saturation:&s brightness:&b alpha:&a];
    s += 0.25;
    if (s > 1.0) s = 1.0;
    
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
    
}

-(void)calculateTrackAttributesFromColor:(UIColor*)color {
    self.apiManager = [[SCAPIManager alloc]initWithColor:color coordinator:self.coordinator];
    
    CGFloat h, s, b, a;
    [self.dominantColor getHue:&h saturation:&s brightness:&b alpha:&a];
}
- (IBAction)getTracksPressed:(UIButton *)sender {
    [self.coordinator goToRecommendationsViewWithAPIManager:self.apiManager];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.coordinator popViewControllerAnimated:YES];
}

@end
