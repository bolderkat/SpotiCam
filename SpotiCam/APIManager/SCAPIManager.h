//
//  SCAPIManager.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCAPIManager : NSObject
// Track attributes for Spotify track recommendation requests
@property (nonatomic) CGFloat danceability;
@property (nonatomic) CGFloat energy;
@property (nonatomic) CGFloat valence;

+ (void)fetchGenreSeedsWithToken:(NSString*)token completion:(void (^)(NSArray<NSString*>*))completion;
- (instancetype)initWithColor:(UIColor *)color coordinator:(SCMainCoordinator*)coordinator;
- (void)fetchTrackRecommendations;

@end

NS_ASSUME_NONNULL_END
