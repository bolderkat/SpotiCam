//
//  SCSettingsTableDataSource.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/24/21.
//

#import "SCSettingsTableDataSource.h"

@implementation SCSettingsTableDataSource
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self snapshot].sectionIdentifiers[section];
}

@end
