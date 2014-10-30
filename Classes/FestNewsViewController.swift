//
//  FestNewsViewController.swift
//  FestApp
//
//  Created by Oleg Grenrus on 30/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation
import UIKit

class NewsTableCellView: UITableViewCell {
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        self.textLabel.textColor = highlighted ? FEST_COLOR_GOLD : UIColor.blackColor()
    }
}

/*

@interface FestNewsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *news;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation FestNewsViewController

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

RACSignal *NewsSignal = FestDataManager.sharedFestDataManager.newsSignal;
[NewsSignal subscribeNext:^(NSArray *news) {
self.news = news;
[self.tableView reloadData];
}];

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
return self.news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
NSUInteger idx = indexPath.row;

static NSString *cellIdentifier = @"NewsItemCell";
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

if (cell == nil) {
cell = [[NewsTableCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
cell.selectionStyle = UITableViewCellSelectionStyleNone;
// cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

NewsItem *NewsItem = self.news[idx];

cell.backgroundColor = [UIColor clearColor];
cell.textLabel.text = NewsItem.title;
cell.detailTextLabel.text = NewsItem.published.description; // TODO
cell.textLabel.textColor = [UIColor blackColor];
cell.textLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:23];

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
NewsItem *newsItem = self.news[indexPath.row];
[APPDELEGATE showNewsItem:newsItem];
}

#pragma clang diagnostic pop

@end

*/