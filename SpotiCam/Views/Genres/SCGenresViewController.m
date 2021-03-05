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
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property SCGenreTableDataSource *dataSource;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
}


- (void)configureViewController {
    self.title = @"Select Genres";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Done"
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(doneButtonPressed)];
    self.navigationItem.hidesBackButton = YES;
    [self updateUI];
}

- (void)loadSelectedGenres {
    self.selectedGenres = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedGenres"] mutableCopy];
    if (self.selectedGenres == nil) {
        self.selectedGenres = [NSMutableArray arrayWithCapacity:5];
        
        
        // TODO: remove genre from array if no longer present among genres fetched from Spotify
    }
}

- (void)fetchGenres {
    [self.genreTable setHidden:YES];
    [self.activityIndicator setHidden:NO];
    [self.activityLabel setHidden:NO];
    [self.activityIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    [self.coordinator.authManager.authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            [weakSelf showTokenError:error];
            [weakSelf showRefreshButton];
        }
        [SCAPIManager fetchGenreSeedsWithToken:accessToken completion:^(NSArray<NSString *> *array, NSDictionary *apiError) {
            NSMutableArray *capitalizedArray = [NSMutableArray array];
            for (NSString *item in array) {
                NSString *capitalizedName = [item capitalizedString];
                BOOL isChecked = NO;
                
                if ([weakSelf.selectedGenres containsObject:capitalizedName]) {
                    isChecked = YES;
                }
                
                SCGenre *genre = [[SCGenre alloc] initWithName:capitalizedName isChecked:isChecked];
                [capitalizedArray addObject:genre];
            }
            weakSelf.genres = [NSArray arrayWithArray:capitalizedArray];
            [weakSelf indexGenresByFirstLetter];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.genreTable setHidden:NO];
                [weakSelf.activityIndicator stopAnimating];
                [weakSelf.activityIndicator setHidden:YES];
                [weakSelf.activityLabel setHidden:YES];
                
                if (apiError) {
                    [weakSelf showRefreshButton];
                    [weakSelf showAlertForApiError:apiError];
                } else if ([weakSelf.genres count] == 0) {
                    [weakSelf showRefreshButton];
                    [weakSelf showNoGenresAlert];
                } else {
                    [weakSelf applyTableViewSnapshot];
                    weakSelf.navigationItem.leftBarButtonItem = nil;
                }
            });
        }];
    }];
}

- (void)showTokenError:(NSError*)error {
    NSString *alertMessage = [NSString stringWithFormat:@"%@. Try fetching genres again. If that does not work, try quitting the app or logging out and back in.", [error localizedDescription]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error getting authorization from Spotify"
                                                                    message:alertMessage
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertForApiError:(NSDictionary*)apiError {
    NSNumber *status = apiError[@"status"];
    NSString *message = apiError[@"message"];
    NSString *alertMessage = [NSString stringWithFormat:@"Error code %@: %@. It looks like the Spotify API may be having issues. Please try again later.", status, message];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Received error from Spotify"
                                                                    message:alertMessage
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showNoGenresAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No genres received"
                                                                   message:@"Succesfully connected to Spotify API but received no genres. There may be an issue with the Spotify API."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showRefreshButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise.circle.fill"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(fetchGenres)];
    self.navigationItem.leftBarButtonItem = button;
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
    [self.coordinator dismissGenresView];
}

#pragma mark - Table View Diffable Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[SCGenreTableDataSource alloc] initWithTableView:self.genreTable
                                                           cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, SCGenre *genre) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:@"genreCell"];
        cell.textLabel.text = genre.name;
        cell.accessoryType = genre.isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.tintColor = [UIColor colorNamed:@"AppGreen"];
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
    [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
}

- (void)configureTableView {
    self.genreTable.delegate = self;
    self.genreTable.sectionIndexColor = [UIColor colorNamed:@"AppGreen"];
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
