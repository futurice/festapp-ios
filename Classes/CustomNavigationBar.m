//
//  CustomNavigationBar.m
//  FestApp
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

@synthesize barColor;

+ (UIColor *)defaultPatternColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_bar"]];
}

+ (UIColor *)defaultTintColor
{
    return kColorRed;
}

- (void)awakeFromNib
{
    self.barColor = [self.class defaultPatternColor];
    self.tintColor = [self.class defaultTintColor];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(c, barColor.CGColor);
    CGContextFillRect(c, rect);
}

@end
