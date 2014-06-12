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
        self.artists = artists;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];

        // TODO: implement our own view.
        UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cellButton.frame = CGRectMake(0, 0, 320, kCellHeight);
        cellButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cellButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        cellButton.titleLabel.numberOfLines = 2;
        cellButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cellButton.imageEdgeInsets = UIEdgeInsetsMake(0, 200, 0, 0);
        cellButton.titleEdgeInsets = UIEdgeInsetsMake(0, -460, 0, 100);
        [cellButton setTitleColor:kColorYellowLight forState:UIControlStateNormal];
        [cellButton addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cellButton.tag = kCellButtonTag;
        [cell addSubview:cellButton];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.backgroundColor = (idx % 2 == 0) ? RR_COLOR_LIGHTGREEN : RR_COLOR_GREEN;

    Artist *artist = self.artists[idx];

    UIButton *cellButton = [UIButton cast:[cell viewWithTag:kCellButtonTag]];

   [[[FestImageManager sharedFestImageManager] imageSignalFor:artist.imagePath] subscribeNext:^(UIImage *image) {
       [cellButton setImage:image forState:UIControlStateNormal];
   }];

    NSString *title = artist.artistName;

    [cellButton setTitle:title forState:UIControlStateNormal];

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
