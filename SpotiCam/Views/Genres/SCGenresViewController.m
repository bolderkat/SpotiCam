//
//  SCGenresViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/17/21.
//

#import "SCGenresViewController.h"
#import "SCAPIManager.h"
#import <OIDAuthState.h>

@interface SCGenresViewController ()
@property (weak, nonatomic) IBOutlet UITableView *genreTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SCGenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select Genres";
    [self configureTableView];
    [self configureSearchBar];
    [self fetchGenres];
}

- (void)configureTableView {
    self.genreTable.delegate = self;
}

- (void)configureSearchBar {
    self.searchBar.delegate = self;
}

- (void)fetchGenres {
    [self.coordinator.authManager.authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching fresh tokens: %@", [error localizedDescription]);
        }
        
        [SCAPIManager fetchGenreSeedsWithToken:accessToken completion:^(NSArray<NSString *> *array) {
            [self displayGenresWithArray:array];
        }];
    }];
}

- (void)displayGenresWithArray:(NSArray<NSString*>*)array {
    for (NSString *item in array) {
        NSLog(@"%@\n", item);
    }
}


@end
