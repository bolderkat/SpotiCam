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
@property (weak, nonatomic) IBOutlet UILabel *danceabilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *hLabel;
@property (weak, nonatomic) IBOutlet UILabel *sLabel;
@property (weak, nonatomic) IBOutlet UILabel *bLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (nonatomic) UIColor *dominantColor;

@end

@implementation SCProcessingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    self.dominantColor = [self getDominantColorFromPhoto];
    self.colorView.backgroundColor = self.dominantColor;
    [self calculateTrackAttributesFromColor:self.dominantColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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
    self.danceabilityLabel.text = [NSString stringWithFormat:@"Danceability: %.2f", self.apiManager.danceability];
    self.energyLabel.text = [NSString stringWithFormat:@"Energy: %.2f", self.apiManager.energy];
    self.valenceLabel.text = [NSString stringWithFormat:@"Valence: %.2f", self.apiManager.valence];
    self.hLabel.text = [NSString stringWithFormat:@"H: %.2f", h];
    self.sLabel.text = [NSString stringWithFormat:@"S: %.2f", s];
    self.bLabel.text = [NSString stringWithFormat:@"B: %.2f", b];
}
- (IBAction)getTracksTapped:(UIButton *)sender {
    [self.coordinator goToRecommendationsViewWithAPIManager:self.apiManager];
}

@end
