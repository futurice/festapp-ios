//
//  FestGigsViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestArtistsViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestArtistCell.h"

@interface FestArtistsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *gigs;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

#define kCellButtonTag 1000
#define kCellHeight 59

@implementation FestArtistsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Subscribe
    RACSignal *gigsSignal = [FestDataManager.sharedFestDataManager gigsSignal];
    [gigsSignal subscribeNext:^(NSArray *gigs) {
        NSArray *sortedGigs = [gigs sortedArrayUsingComparator:^NSComparisonResult(Gig* a, Gig *b) {
            return [a.gigName compare:b.gigName];
        }];

        self.gigs = sortedGigs;
        [self.tableView reloadData];
    }];

    // back button
    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gigs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;

    static NSString *cellIdentifier = @"FestArtistCell";
    FestArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"FestArtistCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }

    cell.backgroundColor = [UIColor clearColor];// (idx % 2 == 0) ? PJ_COLOR_LIGHT : PJ_COLOR_DARK;
    cell.gig = self.gigs[idx];

    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}

#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gig *gig = self.gigs[indexPath.row];
    [APPDELEGATE showGig:gig];
}

#pragma clang diagnostic pop

@end
