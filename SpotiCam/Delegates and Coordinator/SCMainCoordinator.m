//
//  DLMainCoordinator.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import "SCMainCoordinator.h"
#import "SCMainViewController.h"
#import "SCProcessingViewController.h"
#import "SCAuthViewController.h"
#import "SCSettingsViewController.h"
#import "SCGenresViewController.h"
#import "SCRecommendationsViewController.h"
#import "SCAPIManager.h"

@interface SCMainCoordinator ()
@property NSMutableArray *childCoordinators;
@end

@implementation SCMainCoordinator
- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) return nil;
    
    self.window = window;
    self.authManager = [SCAuthManager new];
    self.authManager.coordinator = self;
    [self.authManager loadState];
    return self;
}

- (void)start {
    self.navigationController = [UINavigationController new];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor systemGreenColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    if (self.authManager.authState == nil) {
        UIViewController <Coordinated> *vc = [SCAuthViewController new];
        self.authManager.viewController = vc;
        vc.coordinator = self;
        [self.navigationController pushViewController:vc animated:NO];
    } else {
        [self proceedAfterAuth];
    }
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
}

- (void)proceedAfterAuth {
    UIViewController <Coordinated> *vc;
    NSArray *genres = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedGenres"];
    
    if (genres == nil || [genres count] == 0) {
        vc = [SCGenresViewController new];
        [self.navigationController setNavigationBarHidden:NO];
        vc.navigationItem.hidesBackButton = YES;
    } else {
        vc = [SCMainViewController new];
    }
    vc.coordinator = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToSettingsView {
    SCSettingsViewController *vc = [SCSettingsViewController new];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)goToProcessingViewWithImage:(UIImage*)image {
    SCProcessingViewController *vc = [SCProcessingViewController new];
    vc.coordinator = self;
    vc.image = image;
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)goToRecommendationsViewWithAPIManager:(SCAPIManager*)apiManager {
    SCRecommendationsViewController *vc = [[SCRecommendationsViewController alloc]
                                           initWithNibName:nil
                                           bundle:nil
                                           apiManager:apiManager];
    vc.coordinator = self;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
