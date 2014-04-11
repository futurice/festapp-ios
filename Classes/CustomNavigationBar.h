//
//  CustomNavigationBar.h
//  FestApp
//
//

#import <UIKit/UIKit.h>

@interface CustomNavigationBar : UINavigationBar

@property (strong, nonatomic) UIColor *barColor;

+ (UIColor *)defaultPatternColor;
+ (UIColor *)defaultTintColor;

@end
