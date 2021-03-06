//
//  DLMainCoordinator.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/10/21.
//

#import "SCMainCoordinator.h"
#import "SCMainViewController.h"
#import "SCCameraViewController.h"
#import "SCProcessingViewController.h"
#import "SCAuthViewController.h"
#import "SCSettingsViewController.h"
#import "SCGenresViewController.h"
#import "SCRecommendationsViewController.h"
#import "SCTipViewController.h"
#import "SCInfoViewController.h"
#import "SCPrivacyViewController.h"
#import "SCAPIManager.h"
#import "SCIAPHelper.h"

static NSString *const kAppAuthStateKey = @"authState";
static NSString *const kSelectedGenresKey = @"selectedGenres";
static NSString *const kPopularityKey = @"popularity";

@interface SCMainCoordinator ()
@property NSMutableArray *childCoordinators;
@property (nonatomic) SCIAPHelper *store;
@end

@implementation SCMainCoordinator
- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) return nil;
    
    self.window = window;
    self.authManager = [SCAuthManager new];
    self.store = [SCIAPHelper new];
    self.authManager.coordinator = self;
    [self.authManager loadState];
    return self;
}

- (void)start {
    self.navigationController = [UINavigationController new];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorNamed:@"AppGreen"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    BOOL hasUserAuthorizedPlaylistScope = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasUserAuthorizedPlaylistScope"];
    
    // Need to reauthorize if user has logged in but before v1.1 when playlist creation scope was added to auth
    if (self.authManager.authState == nil || !hasUserAuthorizedPlaylistScope) {
        SCAuthViewController *vc = [SCAuthViewController new];
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
    NSArray *genres = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedGenresKey];
    
    if (genres == nil || [genres count] == 0) {
        vc = [SCGenresViewController new];
    } else {
        vc = [SCMainViewController new];
    }
    vc.coordinator = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dismissGenresView {
    // Proceed to main VC if onboarding, otherwise return user to settings VC
    NSInteger currentNavIndex = [self.navigationController.viewControllers count] - 1;
    if (currentNavIndex >= 1 && [self.navigationController.viewControllers[currentNavIndex - 1] isKindOfClass:[SCSettingsViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self proceedAfterAuth];
    }
}

- (void)goToCameraView {
    SCCameraViewController *vc = [SCCameraViewController new];
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
    CATransition* transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)goToRecommendationsViewWithAPIManager:(SCAPIManager*)apiManager {
    SCRecommendationsViewController *vc = [[SCRecommendationsViewController alloc]
                                           initWithNibName:nil
                                           bundle:nil
                                           apiManager:apiManager];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    // Remove ProcessingVC from nav stack to allow user to retake/reselect photo more quickly
    NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs removeObjectAtIndex:[vcs count] - 2];
    [self.navigationController setViewControllers:vcs];
}

- (void)openGenresFromSettings {
    SCGenresViewController *vc = [SCGenresViewController new];
    vc.coordinator = self;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openTipJar {
    SCTipViewController *vc = [[SCTipViewController alloc] initWithStore:self.store];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openInfo {
    SCInfoViewController *vc = [SCInfoViewController new];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openPrivacyPolicy {
    SCPrivacyViewController *vc = [SCPrivacyViewController new];
    vc.coordinator = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)logOut {
    [self.authManager setAuthState:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kSelectedGenresKey];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kPopularityKey];
    
    SCAuthViewController *vc = [SCAuthViewController new];
    self.authManager.viewController = vc;
    vc.coordinator = self;
    
    // Need to replace nav c stack to be able to pop and animate leftward to auth VC.
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    array[0] = vc;
    [self.navigationController setViewControllers:array];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated; {
    [self.navigationController popViewControllerAnimated:animated];
}

@end
