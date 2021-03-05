//
//  SCSettingsRowCellViewModel.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import "SCSettingsRowCellViewModel.h"

@interface SCSettingsRowCellViewModel ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) UIColor *textColor;
@property (nonatomic, copy, nullable) UIImage *image;

@end

@implementation SCSettingsRowCellViewModel
+ (SCSettingsRowCellViewModel*)sliderRow {
    return [[SCSettingsRowCellViewModel alloc] initWithTitle:@"Slider"
                                                   textColor:nil
                                                       image:nil];
}

+ (SCSettingsRowCellViewModel*)genreRow {
    return [[SCSettingsRowCellViewModel alloc] initWithTitle:@"Change Genres"
                                                   textColor:[UIColor whiteColor]
                                                       image:[UIImage systemImageNamed:@"music.note.list"]];
}

+ (SCSettingsRowCellViewModel*)tipJarRow {
    return [[SCSettingsRowCellViewModel alloc] initWithTitle:@"Tip Jar"
                                                   textColor:[UIColor whiteColor]
                                                       image:[UIImage systemImageNamed:@"heart.text.square.fill"]];
}

+ (SCSettingsRowCellViewModel*)infoRow {
    return [[SCSettingsRowCellViewModel alloc] initWithTitle:@"Info"
                                                   textColor:[UIColor whiteColor]
                                                       image:[UIImage systemImageNamed:@"info.circle.fill"]];
}

+ (SCSettingsRowCellViewModel*)privacyPolicyRow {
    return [[SCSettingsRowCellViewModel alloc] initWithTitle:@"Privacy Policy"
                                                   textColor:[UIColor whiteColor]
                                                       image:[UIImage systemImageNamed:@"hand.raised.fill"]];
}

+ (SCSettingsRowCellViewModel*)logOutRow {
    return [[SCSettingsRowCellViewModel alloc] initWithTitle:@"Log Out"
                                                   textColor:[UIColor redColor]
                                                       image:[UIImage systemImageNamed:@"return"]];
}

- (instancetype)initWithTitle:(NSString*)title textColor:(UIColor*)textColor image:(UIImage*)image {
    self.title = title;
    self.textColor = textColor;
    self.image = image;
    
    return self;
}
@end
