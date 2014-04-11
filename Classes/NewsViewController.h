//
//  NewsViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import "NavigableContentViewController.h"

#define kNewsCellWidth      284
#define kNewsCellLabelWidth 240
#define kNewsCellTitleLabelFontSize 18

@interface NewsViewController : NavigableContentViewController
- (void)setContentItems:(NSArray *)news;
@end
