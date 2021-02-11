//
//  DLMainCoordinator.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import "DLMainCoordinator.h"
#import "DLMainViewController.h"
#import "DLProcessingViewController.h"

@interface DLMainCoordinator ()
@property NSMutableArray *childCoordinators;
@end

@implementation DLMainCoordinator
- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) return nil;
    
    self.window = window;
    return self;
}

- (void)start {
    self.navigationController = [UINavigationController new];
    
    DLMainViewController *vc = [DLMainViewController new];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:NO];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
}

- (void)goToProcessingViewWithImage:(UIImage*)image {
    DLProcessingViewController *vc = [DLProcessingViewController new];
    vc.coordinator = self;
    vc.image = image;
    
    [self.navigationController pushViewController:vc animated:NO];
}

@end
