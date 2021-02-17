//
//  SCGenresViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/17/21.
//

#import "SCGenresViewController.h"

@interface SCGenresViewController ()
@property (weak, nonatomic) IBOutlet UITableView *genreTable;

@end

@implementation SCGenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select Genres";
}

- (void)configureTableView {
    self.genreTable.delegate = self;
}




@end
