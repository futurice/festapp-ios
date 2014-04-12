//
//  NavigableContentViewController.m
//  FestApp
//

#import "NavigableContentViewController.h"
#import "WebContentViewController.h"
#import "GigViewController.h"
#import "Gig.h"
#import "UIViewController+Additions.h"

#define kCellButtonTag 1000

@interface NavigableContentViewController ()

- (NSArray *)indexItemsForSection:(NSUInteger)section;
- (NSArray *)indexItemsForIndex:(NSString *)index;

@end

@implementation NavigableContentViewController

@synthesize contentItems;
@synthesize contentItemsByIndices;
@synthesize table;
@synthesize showIndex;
@synthesize detailViewer;

- (void)viewDidLoad
{
    [super viewDidLoad];

    showIndex = [self.title isEqual:NSLocalizedString(@"title.bands", @"")];

    self.detailViewer = [[WebContentViewController alloc] initWithNibName:@"WebContentView" bundle:nil];
    [detailViewer view];  // preload

    [self.tabBarController sendEventToTracker:self.title];

    UIView *footer = [[UIView alloc] init];
    footer.frame = CGRectMake(0, 0, 320, 14);
    self.table.tableFooterView = footer;
    self.table.contentInset = UIEdgeInsetsMake(0, 0, -footer.height, 0);

    if (iOS7 && self.navigationController.viewControllers.count > 1) {
        self.table.frame = CGRectMake(0, 64, 320, self.view.height - (64 + 44));
        self.topCurtainView.y = 64;
        self.backgroundView.y = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.contentItemsByIndices = nil;
    if (showIndex) {
        NSArray *indices = [kIndices componentsSeparatedByString:@","];
        NSMutableDictionary *newContentItemsByIndices = [NSMutableDictionary dictionaryWithCapacity:[indices count]];
        for (NSString *index in indices) {
            NSArray *indexItems = [self indexItemsForIndex:index];
            [newContentItemsByIndices setValue:indexItems forKey:index];
        }
        self.contentItemsByIndices = newContentItemsByIndices;
    }

    [self.navigationItem performSelector:@selector(setTitle:) withObject:nil afterDelay:0.15];
    [table reloadData];
}

- (void)setContentItemsWithDictionary:(NSDictionary *)dictionary
{
    NSArray *keysInOrder = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:[keysInOrder count]];

    for (NSString *key in keysInOrder) {
        id contentItem = dictionary[key];
        NSDictionary *contentItemDict = @{ key: contentItem };
        [contentArray addObject:contentItemDict];
    }

    self.contentItems = contentArray;
}

- (NSArray *)indexItemsForSection:(NSUInteger)section
{
    NSString *indexLetter = [kIndices componentsSeparatedByString:@","][section - 1];
    return [self indexItemsForIndex:indexLetter];
}

- (NSArray *)indexItemsForIndex:(NSString *)indexLetter
{
    if (contentItemsByIndices != nil) {
        return [contentItemsByIndices valueForKey:indexLetter];
    }

    NSMutableArray *indexItems = [NSMutableArray array];
    for (NSDictionary *contentItemDict in self.contentItems) {
        NSString *contentItemTitle = [[contentItemDict allKeys] lastObject];
        NSString *firstLetterOfTitle = [[contentItemTitle substringToIndex:1] uppercaseString];
        // NSLog(@"comparing %@ to %@", indexLetter, firstLetterOfTitle);
        if ([firstLetterOfTitle compare:indexLetter] == 0) {
            [indexItems addObject:contentItemDict];
        }
    }
    // NSLog(@"index items for %@: %d", indexLetter, [indexItems count]);
    return indexItems;
}

- (void)cellButtonPressed:(UIButton *)sender
{
    CGPoint point = [self.table convertPoint:CGPointZero fromView:sender];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:point];
    [self tableView:self.table didSelectRowAtIndexPath:indexPath];
}

#pragma mark UITableViewDataSource

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (showIndex) {
        return (NSInteger) [[kIndices componentsSeparatedByString:@","] count]+1;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (showIndex) {

        if (section == 0) {
            return 1;
        }

        return [[self indexItemsForSection:section] count];

    } else {

        return [contentItems count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {

        static NSString *TitleCellIdentifier = @"TitleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier];
            UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue" size:28];
            cell.textLabel.font = titleFont;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundView = nil;
            cell.backgroundColor = [UIColor clearColor];
        }

        cell.textLabel.text = self.title;
        return cell;
    }

    static NSString *CellIdentifier = @"NavigableContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];

        UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cellButton.frame = CGRectMake(0, 0, 320, 75);
        cellButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cellButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(showIndex) ? 20 : 24];
        cellButton.titleLabel.numberOfLines = 2;
        cellButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 30);
        [cellButton setTitleColor:kColorYellowLight forState:UIControlStateNormal];
        [cellButton addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cellButton.tag = kCellButtonTag;
        [cell addSubview:cellButton];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSDictionary *contentItemDict;

    if (showIndex) {

        contentItemDict = [self indexItemsForSection:indexPath.section][indexPath.row];

    } else {

        contentItemDict = contentItems[indexPath.row - 1];
    }

    UIButton *cellButton = [UIButton cast:[cell viewWithTag:kCellButtonTag]];
    NSString *title = [[[contentItemDict allKeys] lastObject] uppercaseString];

    if ([title isEqualToString:@"TURVALLISUUSOHJEET"]) {
        title = @"TURVALLISUUS-\nOHJEET";
    }

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
	if (showIndex) {
		return [kIndices componentsSeparatedByString:@","];
	} else {
		return nil;
	}
}

#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (showIndex && section > 0) {
        if ([[self indexItemsForSection:section] count] == 0) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
            NSString *indexLetter = [kIndices componentsSeparatedByString:@","][section - 1];
            UILabel *indexLabel = [[UILabel alloc] init];
            indexLabel.frame = CGRectMake(20, 0, view.width - 20, view.height);
            indexLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24];
            indexLabel.backgroundColor = [UIColor clearColor];
            indexLabel.text = indexLetter;
            indexLabel.alpha = 0.1f;
            [view addSubview:indexLabel];
            return view;
        }
    }
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
    if (showIndex && section > 0) {
        if ([[self indexItemsForSection:section] count] == 0) {
            return 40;
        } else {
            return 15;
        }
    } else {
        return 15;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (showIndex) {

        if (section == [tableView numberOfSections] - 1) {
            return 30;
        } else {
            return 0;
        }

    } else {

        return 30;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return;
    }

    NSDictionary *contentItemDict;

    if (showIndex) {
        contentItemDict = [self indexItemsForSection:indexPath.section][indexPath.row];
    } else {
        contentItemDict = contentItems[indexPath.row - 1];
    }

    id contentItem = [[contentItemDict allValues] lastObject];

    self.navigationItem.title = NSLocalizedString(@"navigation.back", @"");

    if ([contentItem isKindOfClass:Gig.class]) {

        GigViewController *gigViewer = [[GigViewController alloc] initWithNibName:@"GigView" bundle:nil];
        gigViewer.gig = (Gig *) contentItem;
        gigViewer.shouldFavoriteAllAlternatives = YES;
        [self.navigationController pushViewController:gigViewer animated:YES];

    } else if ([contentItem isKindOfClass:NSString.class]) {

        NSString *title = [[contentItemDict allKeys] lastObject];
        NSString *content = contentItem;
        [detailViewer setWebTitle:title subtitle:nil content:content];
        [self.navigationController pushViewController:detailViewer animated:YES];
    }
}

#pragma clang diagnostic pop

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

@end
