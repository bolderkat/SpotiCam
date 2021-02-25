//
//  SCSettingsViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import "SCSettingsViewController.h"
#import "SCSettingsRowCellViewModel.h"
#import "SCPopularityTableViewCell.h"
#import "SCSettingsTableDataSource.h"

@interface SCSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (nonatomic) SCSettingsTableDataSource *dataSource;
@property (nonatomic, copy) NSArray<SCSettingsRowCellViewModel*> *settingsRows;
@property (nonatomic) long popularity;
@end

@implementation SCSettingsViewController

- (instancetype)init {
    if (self == [super init]) {
        self.settingsRows = @[
            [SCSettingsRowCellViewModel genreRow],
            [SCSettingsRowCellViewModel tipJarRow],
            [SCSettingsRowCellViewModel logOutRow]
        ];
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPopularityValue];
    [self configureViewController];
    [self configureTableView];
    [self configureDataSource];
    [self applyTableViewSnapshot];
}

- (void)configureViewController {
    self.title = @"Settings";
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)loadPopularityValue {
    self.popularity = [[NSUserDefaults standardUserDefaults] integerForKey:@"popularity"] ?: 0;
}




#pragma mark:- Table View Data Source and Delegate
- (void)configureDataSource {
    self.dataSource = [[SCSettingsTableDataSource alloc]
                       initWithTableView:self.settingsTable
                       cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, SCSettingsRowCellViewModel *rowVM) {
        if ([rowVM.title isEqualToString:@"Slider"]) {
            SCPopularityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SCPopularityTableViewCell"
                                                                              forIndexPath:indexPath];
            cell.slider.value = self.popularity;
            cell.numberLabel.text = [NSString stringWithFormat:@"%ld", self.popularity];
            cell.sliderDidChange = ^(long value) {
                [[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"popularity"];
                self.popularity = value;
            };
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:@"settingsCell"];
            UIListContentConfiguration *content = [cell defaultContentConfiguration];
            content.text = rowVM.title;
            content.image = rowVM.image;
            cell.contentConfiguration = content;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tintColor = [rowVM.title isEqualToString:@"Log Out"] ? [UIColor systemRedColor] : [UIColor systemGreenColor];
            return cell;
        }
    }];
}

- (void)configureTableView {
    self.settingsTable.delegate = self;
    [self.settingsTable registerNib:[UINib nibWithNibName:@"SCPopularityTableViewCell" bundle:nil]
             forCellReuseIdentifier:@"SCPopularityTableViewCell"];
}

- (void)applyTableViewSnapshot {
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    NSArray<NSString*> *sections = @[@"Minimum Track Popularity", @"Other Settings"];
    [snapshot appendSectionsWithIdentifiers:sections];
    [snapshot appendItemsWithIdentifiers:@[[SCSettingsRowCellViewModel sliderRow]]
               intoSectionWithIdentifier:sections[0]];
    [snapshot appendItemsWithIdentifiers:self.settingsRows
               intoSectionWithIdentifier:sections[1]];
    [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end