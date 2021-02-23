//
//  SCRecommendationsViewController.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/22/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"
#import "SCAPIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCRecommendationsViewController : UIViewController
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@property (nonatomic) SCAPIManager *apiManager;

- (instancetype)initWithNibName:( NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil
                     apiManager:(SCAPIManager *)apiManager;

@end

NS_ASSUME_NONNULL_END
