//
//  SCRecommendationsViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/22/21.
//

#import "SCRecommendationsViewController.h"
#import "SCTrack.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SCRecommendationsViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIView *activityBackgroundView;
@property (weak, nonatomic) IBOutlet UITableView *trackTable;
@property (nonatomic) NSArray<SCTrack*> *tracks;
@property (nonatomic) UITableViewDiffableDataSource *dataSource;
@property (nonatomic) BOOL isReturningFromSettings;

@end

@implementation SCRecommendationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Recommendations";
    [self.trackTable setHidden:YES];
    [self configureRightBarButton];
    self.activityBackgroundView.layer.cornerRadius = 15;
    [self fetchTrackRecommendations];
    [self configureDataSource];
    [self configureTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.isReturningFromSettings) {
        [self fetchTrackRecommendations];
        self.activityBackgroundView.alpha = 0.75;
        self.activityLabel.textColor = [UIColor labelColor];
        self.isReturningFromSettings = NO;
    }
}

- (instancetype)initWithNibName:( NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil
                     apiManager:(SCAPIManager *)apiManager {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.apiManager = apiManager;
        self.isReturningFromSettings = NO;
        return self;
    }
    return nil;
}

- (void)configureRightBarButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gearshape.fill"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(showOptions)];
    self.navigationItem.rightBarButtonItem = button;
    
}

- (void)fetchTrackRecommendations {
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [self.activityLabel setHidden:NO];
    [self.activityBackgroundView setHidden:NO];
    __weak typeof(self) weakSelf = self;
    [self.apiManager fetchTrackRecommendationsWithCompletion:^(NSArray<SCTrack*> *tracks, NSDictionary *apiError) {
        weakSelf.tracks = tracks;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.trackTable setHidden:NO];
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.activityIndicator setHidden:YES];
            [weakSelf.activityLabel setHidden:YES];
            [weakSelf.activityBackgroundView setHidden:YES];
            if (apiError) {
                [weakSelf showAlertForApiError:apiError];
            } else if ([weakSelf.tracks count] == 0) {
                [weakSelf showNoTracksAlert];
            }
            [weakSelf applyTableViewSnapshot];
        });
    }];
}

- (void)showAlertForApiError:(NSDictionary*)apiError {
    NSNumber *status = apiError[@"status"];
    NSString *message = apiError[@"message"];
    NSString *alertMessage = [NSString stringWithFormat:@"Error code %@: %@. Please try again later.", status, message];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Received error from Spotify"
                                                                    message:alertMessage
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showNoTracksAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No tracks received"
                                                                   message:@"Succesfully connected to Spotify API but received no tracks. Try lowering your minimum track popularity or changing your selected genres. If you repeatedly get this error even after changing settings, the Spotify API may be having issues."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Open settings"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self openSettings];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Playlist Creation Methods

- (void)showOptions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Options"
                                                                   message:@"Open settings to change minimum track popularity and your selected genres. Returning to this page will request new tracks with updated settings."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Open settings"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self openSettings];
    }]];
    if ([self.tracks count] >= 1) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Create Spotify playlist with tracks"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self showPlaylistDetailEntry];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPlaylistDetailEntry {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create New Spotify Playlist"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Playlist name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Description";
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }];
    
    __weak typeof(alert) weakAlert = alert;
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = weakAlert.textFields.firstObject.text;
        if ([name isEqualToString: @""]) {
            name = @"SpotiCam Playlist";
        }
        
        NSString *description = weakAlert.textFields.lastObject.text;
        if ([description isEqualToString: @""]) {
            description = @"Playlist created with the SpotiCam app on iOS.";
        }
        
        NSDictionary *playlistData = @{
            @"name": name,
            @"description": description,
            @"public": @"true"
        };
        [self.apiManager createPlaylistWithTracks:weakSelf.tracks playlistData:playlistData completionHandler:^(NSString *urlString, NSDictionary * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showPlaylistCompletionAlertWithURLString:urlString error:error];
            });
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPlaylistCompletionAlertWithURLString:(NSString* _Nullable)urlString error:(NSDictionary* _Nullable)error {
    if (error) {
        [self showAlertForApiError:error];
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Playlist successfully created!"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        [alert addAction:[UIAlertAction actionWithTitle:@"Open Playlist"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                     completionHandler:nil];
        }]];
    }
}

- (void)openSettings {
    self.isReturningFromSettings = YES;
    [self.coordinator goToSettingsView];
}

#pragma mark - Table View Diffable Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.trackTable cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, SCTrack *track) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"trackCell"];
        UIListContentConfiguration *content = [cell defaultContentConfiguration];
        content.text = track.trackTitle;
        content.secondaryText = [track.artists componentsJoinedByString:@", "];
        
        content.image = [UIImage systemImageNamed:@"music.note"];
        cell.contentConfiguration = content;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if ([track.albumArtURLs count] == 3) {
            NSString *imageURLString = track.albumArtURLs[2][@"url"]; // 64x64 image
            [manager loadImageWithURL:[NSURL URLWithString:imageURLString]
                              options:0
                             progress:nil
                            completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                content.image = image;
                cell.contentConfiguration = content;
            }];
        }
        return cell;
    }];
}

- (void)applyTableViewSnapshot {
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[@"Main"]];
    [snapshot appendItemsWithIdentifiers:self.tracks];
    [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
}

- (void)configureTableView {
    self.trackTable.delegate = self;
    self.trackTable.rowHeight = 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = self.tracks[indexPath.row].url;
    [[UIApplication sharedApplication] openURL:url
                                       options:@{}
                             completionHandler:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
