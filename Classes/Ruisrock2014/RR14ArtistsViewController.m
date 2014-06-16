//
//  RR14ArtistsViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14ArtistsViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "RR14ArtistViewCell.h"

@interface RR14ArtistsViewController ()
@property (nonatomic, strong) NSArray *artists;
@end

#define kCellButtonTag 1000
#define kCellHeight 59

@implementation RR14ArtistsViewController

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
    RACSignal *artistsSignal = [FestDataManager.sharedFestDataManager artistsSignal];
    [artistsSignal subscribeNext:^(NSArray *artists) {
        NSArray *sortedArtists = [artists sortedArrayUsingComparator:^NSComparisonResult(Artist* a, Artist *b) {
            return [a.artistName compare:b.artistName];
        }];

        NSArray *foreignArtists = [sortedArtists filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Artist *artist, NSDictionary *bindings) {
            return artist.country != nil;
        }]];

        self.artists = [foreignArtists arrayByAddingObjectsFromArray:sortedArtists] ;
        [self.tableView reloadData];
    }];

    // back button
    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];

    // table background
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_pattern_light.png"]];
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
    return self.artists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;

    static NSString *CellIdentifier = @"ArtistCell";
    RR14ArtistViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"RR14ArtistCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        /*
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        */
    }

    cell.backgroundColor = (idx % 2 == 0) ? RR_COLOR_LIGHTGREEN : RR_COLOR_GREEN;

    cell.artist = self.artists[idx];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Artist *artist = self.artists[indexPath.row];
    [APPDELEGATE showArtist:artist];
}

#pragma clang diagnostic pop

@end
