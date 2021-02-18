//
//  SCGenre.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/17/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCGenre : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic) BOOL isChecked;

- (instancetype)initWithName:(NSString*)name isChecked:(BOOL)isChecked;
@end

NS_ASSUME_NONNULL_END
