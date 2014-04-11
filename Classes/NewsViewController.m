//
//  NewsViewController.m
//  FestApp
//

#import "NewsViewController.h"
#import "WebContentViewController.h"
#import "UIViewController+Additions.h"

#import "FestDataManager.h"

#define kCellTitleLabelWidth 240
#define kCellTitleFontSize   20

#define kCellTitleLabelTag           2
#define kCellDetailLabelTag          3
#define kCellMiddleBackgroundViewTag 6
#define kCellBottomBackgroundViewTag 7

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"title.news", @"")];

    // Subscribe
    RACSignal *newsSignal = [FestDataManager.sharedFestDataManager signalForResource:FestResourceNews];
    [newsSignal subscribeNext:^(id news) {
        [self setContentItems:news];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController sendEventToTracker:self.title];

    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLatestSeenNewsPubDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Try to refresh gigs
    [FestDataManager.sharedFestDataManager reloadResource:FestResourceNews forced:NO];

    [self.navigationController.tabBarItem performSelector:@selector(setBadgeValue:) withObject:nil afterDelay:0.5];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.navigationController.tabBarItem setBadgeValue:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    static NSString *CellIdentifier = @"NewsContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];

        UIImageView *cellTopBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"content_area_top"] stretchableImageWithLeftCapWidth:20 topCapHeight:20]];
        UIImageView *cellMiddleBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"content_area_middle"] stretchableImageWithLeftCapWidth:20 topCapHeight:6]];
        UIImageView *cellBottomBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"content_area_bottom_low"] stretchableImageWithLeftCapWidth:20 topCapHeight:20]];

        cellTopBackgroundView.frame = CGRectMake(1, 0, kNewsCellWidth, 73);
        cellMiddleBackgroundView.tag = kCellMiddleBackgroundViewTag;
        cellBottomBackgroundView.tag = kCellBottomBackgroundViewTag;

        [cell addSubview:cellTopBackgroundView];
        [cell addSubview:cellMiddleBackgroundView];
        [cell addSubview:cellBottomBackgroundView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        UIFont *titleFont = [UIFont fontWithName:@"Futura" size:kNewsCellTitleLabelFontSize];
        titleLabel.font = titleFont;
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.tag = kCellTitleLabelTag;
        [cell addSubview:titleLabel];

        UILabel *detailLabel = [[UILabel alloc] init];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = [UIColor darkGrayColor];
        UIFont *detailFont = [UIFont fontWithName:@"Futura" size:13];
        detailLabel.font = detailFont;
        detailLabel.tag = kCellDetailLabelTag;
        [cell addSubview:detailLabel];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary *contentItemDict = self.contentItems[indexPath.row - 1];

    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];

    UILabel *titleLabel = (UILabel *) [cell viewWithTag:kCellTitleLabelTag];
    UILabel *detailLabel = (UILabel *) [cell viewWithTag:kCellDetailLabelTag];

    titleLabel.text = contentItemDict[@"title"];

    NSTimeInterval pubDateTime = [contentItemDict[@"time"] doubleValue];
    NSDate *pubDate = [NSDate dateWithTimeIntervalSince1970:pubDateTime];
    NSDateFormatter *formatter = [NSDate dateFormatterWithFormat:@"dd.MM.yyyy  HH:mm"];
    detailLabel.text = [formatter stringFromDate:pubDate];

    titleLabel.frame = CGRectMake(24, 4, kNewsCellLabelWidth, cellHeight-40);
    detailLabel.frame = CGRectMake(24, cellHeight-43, kNewsCellLabelWidth, 20);

    UIView *cellMiddleBackgroundView = [cell viewWithTag:kCellMiddleBackgroundViewTag];
    UIView *cellBottomBackgroundView = [cell viewWithTag:kCellBottomBackgroundViewTag];

    cellMiddleBackgroundView.frame = CGRectMake(1, 73, kNewsCellWidth, cellHeight-22-73);
    cellBottomBackgroundView.frame = CGRectMake(1, cellHeight-22, kNewsCellWidth, 22);

    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }

    NSDictionary *contentItemDict = self.contentItems[indexPath.row - 1];
    NSString *newsTitle = [contentItemDict valueForKey:@"title"];
    NSString *newsContent = [contentItemDict valueForKey:@"content"];

    [self.detailViewer setWebTitle:newsTitle subtitle:nil content:newsContent];

    self.navigationItem.title = NSLocalizedString(@"navigation.back", @"");
    [self.navigationController pushViewController:self.detailViewer animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    NSDictionary *contentItemDict = self.contentItems[indexPath.row - 1];
    NSString *rowContent = [contentItemDict valueForKey:@"title"];
    UIFont *rowContentFont = [UIFont fontWithName:@"Futura" size:kNewsCellTitleLabelFontSize];
    CGFloat rowContentHeight = [rowContent
                            boundingRectWithSize:CGSizeMake(kNewsCellLabelWidth, 10000)
                            options:NSStringDrawingUsesDeviceMetrics
                            attributes:@{NSFontAttributeName:rowContentFont}
                            context:nil].size.height;
    return rowContentHeight + 73;
}

#pragma clang diagnostic pop

#pragma mark -

- (void)setContentItems:(NSArray *)news
{
    [super setContentItems:news];

    NSDate *latestSeenNewsPubDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLatestSeenNewsPubDateKey];

    if ([NSDate cast:latestSeenNewsPubDate]) {

        NSLog(@"latestSeenNewsPubdate: %@", latestSeenNewsPubDate);

        unsigned int i = 0;
        while (i < [news count]) {
            NSTimeInterval newsPubTime = [news[i][@"time"] doubleValue];
            NSDate *newsPubDate = [NSDate dateWithTimeIntervalSince1970:newsPubTime];
            if ([newsPubDate before:latestSeenNewsPubDate]) {
                break;
            }
            i++;
        }

        if (i > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", i];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }

    } else {

        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

@end
