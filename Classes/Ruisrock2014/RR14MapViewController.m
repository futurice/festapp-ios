//
//  RR14MapViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14MapViewController.h"

#import "FestDataManager.h"
#import "FestAppDelegate.h"

@interface RR14MapViewController ()

@end

@implementation RR14MapViewController

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

    // back button
    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    // minZoom
    CGFloat minZoomScale = MAX(self.scrollView.frame.size.height / self.mapView.frame.size.height,
                               self.scrollView.frame.size.width / self.mapView.frame.size.width);

    self.scrollView.minimumZoomScale = minZoomScale;

    [self.scrollView setZoomScale:minZoomScale animated:YES];
    [self.scrollView setContentOffset:CGPointMake(self.mapView.frame.size.width / 4, 0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate   

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapView;
}

@end
