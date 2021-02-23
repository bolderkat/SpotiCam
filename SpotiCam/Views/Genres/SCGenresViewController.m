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
#import "SCGenreTableDataSource.h"

@interface SCGenresViewController ()
@property (nonatomic) NSArray<SCGenre*> *genres;
@property (nonatomic) NSMutableArray<NSString*> *genreFirstLetters;
@property (nonatomic) NSMutableArray<NSMutableArray<SCGenre*>*> *genresIndexedByFirstLetter;
@property (nonatomic) NSArray<SCGenre*> *searchResults;
@property (nonatomic) NSMutableArray<NSString*> *selectedGenres;
@property (weak, nonatomic) IBOutlet UITableView *genreTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *selectedGenreLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property SCGenreTableDataSource *dataSource;

@end

@implementation SCGenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.genreTable setHidden:YES];
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
    [self.activityIndicator startAnimating];
    [self.coordinator.authManager.authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching fresh tokens: %@", [error localizedDescription]);
        }
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
            [self indexGenresByFirstLetter];
            
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.genreTable setHidden:NO];
                [self.activityIndicator stopAnimating];
                [self.activityIndicator setHidden:YES];
                [weakSelf applyTableViewSnapshot];
            });
        }];
    }];
}

- (void)indexGenresByFirstLetter {
    self.genreFirstLetters = [NSMutableArray array];
    self.genresIndexedByFirstLetter = [NSMutableArray array];
    NSInteger index = 0;
    for (SCGenre* genre in self.genres) {
        NSString *firstLetter = [genre.name substringToIndex:1];
        if (![self.genreFirstLetters containsObject:firstLetter]) {
            [self.genreFirstLetters addObject:firstLetter];
            index = [self.genreFirstLetters indexOfObject:firstLetter];
            [self.genresIndexedByFirstLetter addObject:[NSMutableArray arrayWithObject:genre]];
        } else {
            [self.genresIndexedByFirstLetter[index] addObject:genre];
        }
    }
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

- (void)showGenreQuantityAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Genre limit reached"
                                message:@"Spotify's track recommendation service allows selection of up to 5 genres."
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doneButtonPressed {
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedGenres forKey:@"selectedGenres"];
    [self.coordinator proceedAfterAuth];
}

#pragma mark - Table View Diffable Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[SCGenreTableDataSource alloc] initWithTableView:self.genreTable cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, SCGenre *genre) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"genreCell"];
//        NSArray<SCGenre*> *array = (self.searchResults == nil) ? self.genres : self.searchResults;
        cell.textLabel.text = genre.name;
        cell.accessoryType = genre.isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.tintColor = [UIColor systemGreenColor];
        return cell;
    }];
}

-(void)applyTableViewSnapshot {
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    if (self.searchResults == nil) {
        [snapshot appendSectionsWithIdentifiers:self.genreFirstLetters];
        for (int i = 0; i < [self.genreFirstLetters count]; i++) {
            [snapshot appendItemsWithIdentifiers:self.genresIndexedByFirstLetter[i]
                       intoSectionWithIdentifier:self.genreFirstLetters[i]];
        }
    } else {
        [snapshot appendSectionsWithIdentifiers:@[@"Main"]];
        [snapshot appendItemsWithIdentifiers:self.searchResults];
    }
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)configureTableView {
    self.genreTable.delegate = self;
    self.genreTable.sectionIndexColor = [UIColor systemGreenColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<SCGenre*> *array = (self.searchResults == nil) ? self.genresIndexedByFirstLetter[indexPath.section] : self.searchResults;
    SCGenre *selectedGenre = array[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.selectedGenres count] == 5 &&
        selectedGenre.isChecked &&
        [self.selectedGenres containsObject:selectedGenre.name]) {
        // If user unchecking 5th genre
        selectedGenre.isChecked = NO;
        [self.selectedGenres removeObject:selectedGenre.name];
    } else if ([self.selectedGenres count] == 5) {
        // Show alert if trying to check a 6th genre
        [self showGenreQuantityAlert];
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
