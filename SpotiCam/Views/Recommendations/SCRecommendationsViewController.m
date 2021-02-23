//
//  SCRecommendationsViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/22/21.
//

#import "SCRecommendationsViewController.h"
#import "SCTrack.h"

@interface SCRecommendationsViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *trackTable;
@property (nonatomic) NSArray<SCTrack*> *tracks;
@property UITableViewDiffableDataSource *dataSource;

@end

@implementation SCRecommendationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.trackTable setHidden:YES];
    [self fetchTrackRecommendations];
    [self configureDataSource];
    [self configureTableView];
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

- (void)fetchTrackRecommendations {
    [self.activityIndicator startAnimating];
    [self.apiManager fetchTrackRecommendationsWithCompletion:^(NSArray<SCTrack*> *tracks) {
        self.tracks = tracks;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.trackTable setHidden:NO];
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.activityIndicator setHidden:YES];
            [weakSelf applyTableViewSnapshot];
        });
    }];
}



#pragma mark - Table View Diffable Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.trackTable cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, SCTrack *track) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"trackCell"];
        UIListContentConfiguration *content = [cell defaultContentConfiguration];
        content.text = track.trackTitle;
        content.secondaryText = [track.artists componentsJoinedByString:@", "];
        cell.contentConfiguration = content;
        return cell;
    }];
}

- (void)applyTableViewSnapshot {
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[@"Main"]];
    [snapshot appendItemsWithIdentifiers:self.tracks];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)configureTableView {
    self.trackTable.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
