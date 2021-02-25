//
//  SCSettingsRowCellViewModel.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCSettingsRowCellViewModel : NSObject
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly, nullable) UIColor *textColor;
@property (nonatomic, copy, readonly, nullable) UIImage *image;

+ (SCSettingsRowCellViewModel*)sliderRow;
+ (SCSettingsRowCellViewModel*)genreRow;
+ (SCSettingsRowCellViewModel*)tipJarRow;
+ (SCSettingsRowCellViewModel*)logOutRow;
@end

NS_ASSUME_NONNULL_END
