//
//  RR2014ScheduleViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimelineView.h"
#import "DayChooser.h"

@interface RR14ScheduleViewController : UIViewController <TimelineViewDelegate, DayChooserDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet DayChooser *dayChooser;
@property (nonatomic, strong) IBOutlet TimelineView *timeLineView;

@end
