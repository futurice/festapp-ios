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
@property (nonatomic, strong) NSArray *currentArtists;
@property (nonatomic, strong) NSString *currentDay;

- (void)reloadData;
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
        self.artists = artists;
        [self reloadData];
    }];

    self.dayChooser.delegate = self;
    self.dayChooser.dayNames = @[@"Perjantai", @"Lauantai", @"Sunnuntai"];

    // table background
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_pattern_light.png"]];

    // Table header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headerLabel.text = @"BÄNDIT";
    headerLabel.backgroundColor = RR_COLOR_DARKGREEN;
    headerLabel.textColor = RR_COLOR_LIGHTGREEN;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:17];

    UIImageView *waveView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"water_line.png"]];
    waveView.y = 36;

    [headerView addSubview:headerLabel];
    [headerView addSubview:waveView];

    self.tableView.tableHeaderView = headerView;

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

#pragma mark TableDataReload

- (void)reloadData
{
    NSMutableArray *currentArtists = [NSMutableArray arrayWithCapacity:self.artists.count / 2];
    for (Artist *artist in self.artists) {
        if ([artist.day isEqualToString:self.currentDay]) {
            [currentArtists addObject:artist];
        }
    }
    self.currentArtists = currentArtists;
    [self.tableView reloadData];
}

#pragma mark DayChooserDelegate

- (void)dayChooser:(DayChooser *)dayChooser selectedDayWithIndex:(NSUInteger)dayIndex
{
    NSString *currentDay = @"Perjantai";
    switch (dayIndex) {
        case 0: currentDay = @"Perjantai"; break;
        case 1: currentDay = @"Lauantai"; break;
        case 2: currentDay = @"Sunnuntai"; break;
    }

    self.currentDay = currentDay;

    [self reloadData];
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
    return self.currentArtists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;

    static NSString *CellIdentifier = @"ArtistCell";
    RR14ArtistViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"RR14ArtistViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        /*
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        */
    }

    cell.backgroundColor = (idx % 2 == 0) ? RR_COLOR_LIGHTGREEN : RR_COLOR_GREEN;

    cell.artist = self.currentArtists[idx];

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
    Artist *artist = self.currentArtists[indexPath.row];
    [APPDELEGATE showArtist:artist];
}

#pragma clang diagnostic pop

@end
