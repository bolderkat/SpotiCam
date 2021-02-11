//
//  DLMainCoordinator.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import "SCMainCoordinator.h"
#import "SCMainViewController.h"
#import "SCProcessingViewController.h"

@interface SCMainCoordinator ()
@property NSMutableArray *childCoordinators;
@end

@implementation SCMainCoordinator
- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) return nil;
    
    self.window = window;
    return self;
}

- (void)start {
    self.navigationController = [UINavigationController new];
    
    SCMainViewController *vc = [SCMainViewController new];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:NO];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
}

- (void)goToProcessingViewWithImage:(UIImage*)image {
    SCProcessingViewController *vc = [SCProcessingViewController new];
    vc.coordinator = self;
    vc.image = image;
    
    [self.navigationController pushViewController:vc animated:NO];
}

@end
