//
//  SCGenresViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/17/21.
//

#import "SCGenresViewController.h"
#import "SCAPIManager.h"
#import <OIDAuthState.h>
#import "SCGenre.h"

@interface SCGenresViewController ()
@property (nonatomic) NSArray<SCGenre*> *genres;
@property (nonatomic) NSArray<SCGenre*> *searchResults;
@property (nonatomic) NSMutableArray<NSString*> *selectedGenres;
@property (weak, nonatomic) IBOutlet UITableView *genreTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *selectedGenreLabel;
@property UITableViewDiffableDataSource *dataSource;

@end

@implementation SCGenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSelectedGenres];
    [self configureViewController];
    [self configureDataSource];
    [self configureTableView];
    [self configureSearchBar];
    [self fetchGenres];
}


- (void)configureViewController {
    self.title = @"Select Genres";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor systemGreenColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Done"
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(doneButtonPressed)];
    [self updateUI];
}

- (void)loadSelectedGenres {
    self.selectedGenres = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedGenres"] mutableCopy];
    if (self.selectedGenres == nil) {
        self.selectedGenres = [NSMutableArray arrayWithCapacity:5];
    }
}

- (void)fetchGenres {
    [self.coordinator.authManager.authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching fresh tokens: %@", [error localizedDescription]);
        }
        // TODO: show spinner until genres have been fetched
        [SCAPIManager fetchGenreSeedsWithToken:accessToken completion:^(NSArray<NSString *> *array) {
            NSMutableArray *capitalizedArray = [NSMutableArray array];
            for (NSString *item in array) {
                NSString *capitalizedName = [item capitalizedString];
                BOOL isChecked = NO;
                
                if ([self.selectedGenres containsObject:capitalizedName]) {
                    isChecked = YES;
                }
                
                SCGenre *genre = [[SCGenre alloc] initWithName:capitalizedName isChecked:isChecked];
                [capitalizedArray addObject:genre];
            }
            self.genres = [NSArray arrayWithArray:capitalizedArray];
            
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf applyTableViewSnapshot];
            });
        }];
    }];
}

- (void)updateUI {
    self.selectedGenreLabel.text = [self.selectedGenres componentsJoinedByString:@", "];
    
    if ([self.selectedGenres count] == 0) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)doneButtonPressed {
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedGenres forKey:@"selectedGenres"];
    [self.coordinator proceedAfterAuth];
}

#pragma mark - Table View Diffable Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.genreTable cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, id title) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"genreCell"];
        NSArray<SCGenre*> *array = (self.searchResults == nil) ? self.genres : self.searchResults;
        cell.textLabel.text = [array objectAtIndex:indexPath.row].name;
        cell.accessoryType = [array objectAtIndex:indexPath.row].isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.tintColor = [UIColor systemGreenColor];
        return cell;
    }];
}

-(void)applyTableViewSnapshot {
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[@"Main"]];
    
    NSArray<SCGenre*> *array = (self.searchResults == nil) ? self.genres : self.searchResults;
    [snapshot appendItemsWithIdentifiers:array];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    
}

- (void)configureTableView {
    self.genreTable.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<SCGenre*> *array = (self.searchResults == nil) ? self.genres : self.searchResults;
    SCGenre *selectedGenre = array[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.selectedGenres count] == 5 &&
        selectedGenre.isChecked &&
        [self.selectedGenres containsObject:selectedGenre.name]) {
        // If user unchecking 5th genre
        selectedGenre.isChecked = NO;
        [self.selectedGenres removeObject:selectedGenre.name];
    } else if ([self.selectedGenres count] == 5) {
        // Do nothing if trying to check a 6th genre
        // TODO: Maybe display an error message?
        return;
    } else if ([self.selectedGenres containsObject:selectedGenre.name]) {
        [self.selectedGenres removeObject:selectedGenre.name];
        selectedGenre.isChecked = !selectedGenre.isChecked;
    } else {
        [self.selectedGenres addObject:selectedGenre.name];
        selectedGenre.isChecked = !selectedGenre.isChecked;
    }

    [self updateUI];
    [self.genreTable reloadData];
}

#pragma mark- Search Bar Delegate
- (void)configureSearchBar {
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.textColor = [UIColor whiteColor];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.searchResults = nil;
        [self applyTableViewSnapshot];
        return;
    }
    // Case-insensitive search with punctuation (-) ignored
    NSString* processedSearch = [[[searchText lowercaseString]
                                  componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]]
                                 componentsJoinedByString:@""];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SCGenre* obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString* processedGenre = [[[obj.name lowercaseString]
                                     componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]]
                                    componentsJoinedByString:@""];
        return [processedGenre containsString:processedSearch];
    }];
    
    self.searchResults = [self.genres filteredArrayUsingPredicate:predicate];
    [self applyTableViewSnapshot];
    
    
}


@end
