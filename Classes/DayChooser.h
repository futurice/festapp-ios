//
//  DayChooser.h
//  FestApp
//

#import <UIKit/UIKit.h>

@class DayChooser;

@protocol DayChooserDelegate

- (void)dayChooser:(DayChooser *)dayChooser selectedDayWithIndex:(NSUInteger)dayIndex;

@end

@interface DayChooser : UIView

@property (strong, nonatomic) NSArray *dayNames;
@property (nonatomic, assign) NSUInteger selectedDayIndex;
@property (nonatomic, weak) id<DayChooserDelegate> delegate;

- (id)initWithDayNames:(NSArray *)dayNames;

- (IBAction)buttonPressed:(UIButton *)button;

@end
