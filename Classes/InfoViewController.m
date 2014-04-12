//
//  InfoViewController.m
//  FestApp
//

#import "InfoViewController.h"
#import "WebContentViewController.h"
#import "NavigableContentViewController.h"
#import "FestAppDelegate.h"
#import "Gig.h"
#import "UIViewController+Additions.h"
#import "FestDataManager.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

NSArray *sortedArtists(NSArray *gigs);
NSArray *combineGeneralInfo(NSDictionary *generalJson, NSDictionary *faqJSON);

@interface InfoViewController ()
@property (nonatomic, strong) NSDictionary *programJson;
@property (nonatomic, strong) NSDictionary *servicesJson;
@property (nonatomic, strong) NSArray *artists;

@property (nonatomic, strong) NSArray *generalInfo;

- (void)showWebContent:(NSString *)content withTitle:(NSString *)title;
- (void)showNavigableContent:(id)content withTitle:(NSString *)title;
@end

NSArray *sortedArtists(NSArray *gigs)
{
    NSArray *gigsInAlphabeticalOrder = [gigs sortedArrayUsingFunction:alphabeticalGigSort context:NULL];
    NSMutableArray *gigContentDictsInAlphabeticalOrder = [NSMutableArray arrayWithCapacity:gigsInAlphabeticalOrder.count];

    NSMutableArray *uniqueArtistNames = [NSMutableArray arrayWithCapacity:[gigsInAlphabeticalOrder count]];

    for (Gig *gig in gigsInAlphabeticalOrder) {
        NSString *artistName = gig.artistName;
        if (![uniqueArtistNames containsObject:artistName]) {

            [uniqueArtistNames addObject:artistName];
            NSDictionary *gigContentDict = @{artistName: gig};
            [gigContentDictsInAlphabeticalOrder addObject:gigContentDict];
        }
    }

    return gigContentDictsInAlphabeticalOrder;
}

NSArray *combineGeneralInfo(NSDictionary *generalJson, NSDictionary *faqJSON) {
    NSMutableDictionary *generalInfoJSON = [generalJson mutableCopy];

    if (faqJSON[@"content"]) {
        generalInfoJSON[faqJSON[@"title"]] = faqJSON[@"content"];
    }

    NSMutableArray *keysInOrder = [[[generalInfoJSON allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    NSMutableArray *generalInfoArray = [NSMutableArray arrayWithCapacity:[keysInOrder count]];

    for (NSString *key in keysInOrder) {
        id contentItem = generalInfoJSON[key];
        if (contentItem) {
            NSDictionary *contentItemDict = @{key: contentItem};
            [generalInfoArray addObject:contentItemDict];
        }
    }

    return generalInfoArray;
}

@implementation InfoViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

    FestDataManager *dataManager = [FestDataManager sharedFestDataManager];

    // Subscribe
    RAC(self, artists) = [[dataManager signalForResource:FestResourceArtists] map:^id(id value) {
        return sortedArtists(value);
    }];

    RAC(self, generalInfo) = [RACSignal
                              combineLatest:@[[dataManager signalForResource:FestResourceGeneral],
                                              [dataManager signalForResource:FestResourceFaq]]
                              reduce:^id(NSDictionary *generalJson, NSDictionary *faqJSON) {
                                  return combineGeneralInfo(generalJson, faqJSON);
                              }];

    RAC(self, programJson) = [dataManager signalForResource:FestResoucreProgram];
    RAC(self, servicesJson) = [dataManager signalForResource:FestResourceServices];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }

    // Try to refresh gigs
    [FestDataManager.sharedFestDataManager reloadResource:FestResourceArtists forced:NO];

    [self.navigationItem performSelector:@selector(setTitle:) withObject:nil afterDelay:0.15];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [super viewWillDisappear:animated];
}

#pragma mark Actions

- (IBAction)showBands
{
    [self showNavigableContent:self.artists withTitle:NSLocalizedString(@"title.bands", @"")];
}

- (IBAction)showGeneralInfo
{
    [self showNavigableContent:self.generalInfo withTitle:NSLocalizedString(@"title.general", @"")];
}

- (IBAction)showFoodAndDrinks
{
    [self showWebContent:self.programJson[@"content"] withTitle:self.programJson[@"title"]];
}

- (IBAction)showServices
{
    [self showNavigableContent:self.servicesJson withTitle:NSLocalizedString(@"title.services", @"")];
}

- (IBAction)showTransportation
{
    NSError *error;
    NSStringEncoding enc;
    NSString *path = [[NSBundle mainBundle] pathForResource:kResourceNameArrival ofType:@"html"];
    NSString *content = [NSString
                         stringWithContentsOfFile:path
                         usedEncoding:&enc
                         error:&error];
    if (error) {
        NSLog(@"Error reading arrival info: %@", error);
    }
    [self showWebContent:content withTitle:NSLocalizedString(@"title.arrival", @"")];
}

- (void)showWebContent:(NSString *)content withTitle:(NSString *)title
{
    WebContentViewController *viewer = [[WebContentViewController alloc] initWithNibName:@"WebContentView" bundle:nil];

    [viewer setWebTitle:title subtitle:nil content:content];

    self.navigationItem.title = NSLocalizedString(@"navigation.back", @"");
    [self.navigationController pushViewController:viewer animated:YES];
}

- (void)showNavigableContent:(id)content withTitle:(NSString *)title
{
    NavigableContentViewController *viewer = [[NavigableContentViewController alloc] initWithNibName:@"NavigableContentView" bundle:nil];

    viewer.title = title;

    [self.tabBarController sendEventToTracker:title];

    if ([content isKindOfClass:[NSArray class]]) {
        [viewer setContentItems:(NSArray *) content];
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        [viewer setContentItemsWithDictionary:(NSDictionary *) content];
    }

    self.navigationItem.title = NSLocalizedString(@"navigation.back", @"");
    [self.navigationController pushViewController:viewer animated:YES];
}

@end
