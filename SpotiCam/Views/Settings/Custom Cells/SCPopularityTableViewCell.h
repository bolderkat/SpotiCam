//
//  SCPopularityTableViewCell.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCPopularityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, copy, nullable) void (^sliderDidChange)(long);

@end

NS_ASSUME_NONNULL_END
