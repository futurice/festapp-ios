//
//  DayChooser.h
//  FestApp
//

#import <UIKit/UIKit.h>

#define kDayChooserHeight 25

@class DayChooser;

@protocol DayChooserDelegate

- (void)dayChooser:(DayChooser *)dayChooser selectedDayWithIndex:(NSUInteger)dayIndex;

@end

@interface DayChooser : UIView

// Array<String>
@property (nonatomic, strong) NSArray *dayNames;
@property (nonatomic, assign) NSUInteger selectedDayIndex;
@property (nonatomic, weak) id<DayChooserDelegate> delegate;

- (IBAction)buttonPressed:(UIButton *)button;

@end
