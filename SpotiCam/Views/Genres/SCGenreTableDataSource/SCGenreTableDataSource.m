//
//  SCGenreTableDataSource.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/18/21.
//

#import "SCGenreTableDataSource.h"

@implementation SCGenreTableDataSource
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = [self snapshot].sectionIdentifiers;
    
    return [sections[section] isEqualToString:@"Main"] ? nil : sections[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self snapshot].sectionIdentifiers count] == 1 ? nil : [self snapshot].sectionIdentifiers;
}
@end
