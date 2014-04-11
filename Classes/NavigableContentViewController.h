//
//  NavigableContentViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>

#define kIndices @"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,Å,Ä,Ö"

@class WebContentViewController;

@interface NavigableContentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *contentItems;
@property (strong, nonatomic) NSDictionary *contentItemsByIndices;
@property (nonatomic, assign) BOOL showIndex;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) WebContentViewController *detailViewer;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *topCurtainView;

- (void)setContentItemsWithDictionary:(NSDictionary *)dictionary;

@end
