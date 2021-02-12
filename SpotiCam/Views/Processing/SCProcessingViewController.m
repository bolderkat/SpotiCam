//
//  SCProcessingViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import "SCProcessingViewController.h"
#import "SCAPIManager.h"

@interface SCProcessingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *danceabilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valenceLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (nonatomic) UIColor *averageColor;

@end

@implementation SCProcessingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    self.averageColor = [self getAverageColorFromPhoto];
    self.colorView.backgroundColor = self.averageColor;
    [self calculateTrackAttributesFromColor:self.averageColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (UIColor*)getAverageColorFromPhoto {
    // Translated to Obj-C from https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    CIImage *image = [CIImage imageWithCGImage:self.image.CGImage];
    CIVector *extentVector = [CIVector vectorWithX:image.extent.origin.x Y:image.extent.origin.y Z:image.extent.size.width W:image.extent.size.height];
    CIFilter *filter = [CIFilter filterWithName:@"CIAreaAverage" withInputParameters:@{kCIInputImageKey: image, kCIInputExtentKey: extentVector}];
    CIImage *outputImage = [filter outputImage];
    
    uint8_t bitmap[4];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: [NSNull null]}];
    [context render:outputImage toBitmap:bitmap rowBytes:4 bounds:CGRectMake(0, 0, 1, 1) format:kCIFormatRGBA8 colorSpace:nil];
    
    return [UIColor colorWithRed:(CGFloat)bitmap[0] / 255 green:(CGFloat)bitmap[1] / 255 blue:(CGFloat)bitmap[2] / 255 alpha:(CGFloat)bitmap[3] / 255];
}

-(void)calculateTrackAttributesFromColor:(UIColor*)color {
    SCAPIManager *apiManager = [[SCAPIManager alloc]initWithColor:color];
    self.danceabilityLabel.text = [NSString stringWithFormat:@"Danceability: %.2f", apiManager.danceability];
    self.energyLabel.text = [NSString stringWithFormat:@"Energy: %.2f", apiManager.energy];
    self.valenceLabel.text = [NSString stringWithFormat:@"Valence: %.2f", apiManager.valence];
}
@end
