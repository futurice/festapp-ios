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

@interface RR14ArtistsViewController ()
@property (nonatomic, strong) NSArray *artists;
@end

#define kCellButtonTag 1000

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
        [self.tableView reloadData];
    }];

    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];

        UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cellButton.frame = CGRectMake(0, 0, 320, 75);
        cellButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cellButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24];
        cellButton.titleLabel.numberOfLines = 2;
        cellButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 30);
        [cellButton setTitleColor:kColorYellowLight forState:UIControlStateNormal];
        [cellButton addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cellButton.tag = kCellButtonTag;
        [cell addSubview:cellButton];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    Artist *artist = self.artists[idx];

    UIButton *cellButton = [UIButton cast:[cell viewWithTag:kCellButtonTag]];
    NSString *title = [artist.artistName uppercaseString];

    [cellButton setTitle:title forState:UIControlStateNormal];

    cellButton.width = [title
                        boundingRectWithSize:CGSizeMake(240, cellButton.height)
                        options:NSStringDrawingUsesDeviceMetrics
                        attributes:@{NSFontAttributeName:cellButton.titleLabel.font}
                        context:nil].size.width + 50;
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
    return 75 + 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Artist *artist = self.artists[indexPath.row];
    [APPDELEGATE showArtist:artist];
}

#pragma clang diagnostic pop

#pragma mark - HACK

- (void)cellButtonPressed:(UIButton *)sender
{
    CGPoint point = [self.tableView convertPoint:CGPointZero fromView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

@end
