//
//  SCPopularityTableViewCell.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import "SCPopularityTableViewCell.h"

@interface SCPopularityTableViewCell ()

@end

@implementation SCPopularityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)sliderMoved:(UISlider *)sender {
    long rounded = roundf(sender.value);
    self.sliderDidChange(rounded);
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", rounded];
}


@end
