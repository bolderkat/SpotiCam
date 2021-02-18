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
@property (nonatomic) NSArray<NSString*> *genres;
@property (weak, nonatomic) IBOutlet UITableView *genreTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property UITableViewDiffableDataSource *dataSource;

@end

@implementation SCGenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select Genres";
    [self configureDataSource];
    [self configureTableView];
    [self configureSearchBar];
    [self fetchGenres];
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
            NSMutableArray *capitalizedArray = [NSMutableArray array];
            for (NSString *item in array) {
                [capitalizedArray addObject:[(NSString*)item capitalizedString]];
            }
            self.genres = [NSArray arrayWithArray:capitalizedArray];
            [self updateTableView];
        }];
    }];
}

#pragma mark - Table View Diffable Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.genreTable cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, id title) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"genreCell"];
        cell.textLabel.text = [self.genres objectAtIndex:indexPath.row];
        return cell;
    }];
}

-(void)updateTableView {
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[@"Main"]];
    [snapshot appendItemsWithIdentifiers:self.genres];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    
}

- (void)configureTableView {
    self.genreTable.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




@end
