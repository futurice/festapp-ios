//
//  FestRR14InfoViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 14/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestRR14InfoViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface FestRR14InfoViewController ()
@property (nonatomic, strong) NSArray *info;
@end

@implementation FestRR14InfoViewController

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

    RACSignal *infoSignal = FestDataManager.sharedFestDataManager.infoSignal;
    [infoSignal subscribeNext:^(NSArray *info) {
        self.info = info;
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
    return self.info.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;

    static NSString *cellIdentifier = @"InfoItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    InfoItem *infoItem = self.info[idx];

    cell.backgroundColor = (idx % 2 == 0) ? RR_COLOR_LIGHTGREEN : RR_COLOR_GREEN;

    cell.textLabel.text = infoItem.title;
    cell.textLabel.textColor = [UIColor whiteColor];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfoItem *infoItem = self.info[indexPath.row];
    [APPDELEGATE showInfoItem:infoItem];
}

#pragma clang diagnostic pop

@end
