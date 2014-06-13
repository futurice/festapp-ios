//
//  FestRR14InfoViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 14/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FestRR14InfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
