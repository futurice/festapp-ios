//
//  RR14ArtistsViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DayChooser.h"

@interface RR14ArtistsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DayChooserDelegate>
@property (nonatomic, strong) IBOutlet DayChooser *dayChooser;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
