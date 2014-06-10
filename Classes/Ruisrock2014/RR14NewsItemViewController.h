//
//  RR14NewsItemViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RR14NewsItemViewController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel* newsItemLabel;

// TODO: implement news type and take that as param
+ (RR14NewsItemViewController *) newWithNewsItemId:(NSString *)newsItemId;
@end
