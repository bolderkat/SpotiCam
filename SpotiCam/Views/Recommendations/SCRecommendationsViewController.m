//
//  SCRecommendationsViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/22/21.
//

#import "SCRecommendationsViewController.h"

@interface SCRecommendationsViewController ()

@end

@implementation SCRecommendationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Danceability: %.2f", self.apiManager.danceability);
    NSLog(@"Energy: %.2f", self.apiManager.energy);
    NSLog(@"Valence: %.2f", self.apiManager.valence);
}

- (instancetype)initWithNibName:( NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil
                     apiManager:(SCAPIManager *)apiManager {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.apiManager = apiManager;
        return self;
    }
    return nil;
}


@end
