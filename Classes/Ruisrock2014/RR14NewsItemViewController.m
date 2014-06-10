//
//  RR14NewsItemViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14NewsItemViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface RR14NewsItemViewController ()
@property (nonatomic, strong) NSString *newsItemId;
@end

@implementation RR14NewsItemViewController

#pragma mark - Constructor

+ (RR14NewsItemViewController *)newWithNewsItemId:(NSString *)newsItemId
{
    RR14NewsItemViewController *controller = [[RR14NewsItemViewController alloc] initWithNibName:@"RR14NewsItemViewController" bundle:nil];

    // TODO: implement me
    [controller setNewsItemId:newsItemId];

    return controller;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];

    [[self newsItemLabel] setText:[self newsItemId]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
