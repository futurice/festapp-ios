//
//  InfoViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>


@interface InfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

- (IBAction)showBands;
- (IBAction)showGeneralInfo;
- (IBAction)showFoodAndDrinks;
- (IBAction)showServices;
- (IBAction)showTransportation;

@end
