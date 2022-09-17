//
//  MainViewController.m
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface MainViewController ()
{
}
@end

@implementation MainViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[Utils makeXibName:nibNameOrNil] bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [AppDelegate resetSession];
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    self.bannerView.adUnitID = ADMOB_BANNER_ID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) photo: (int)total
{
    OptionsViewController *optionsController = [[OptionsViewController alloc] initWithNibName: @"OptionsViewController" bundle:nil];
    optionsController.total = total;
    optionsController.photo = true;
    [[AppDelegate rootController] pushViewController:optionsController animated:YES];
}

- (void) video: (int)total
{
    OptionsViewController *optionsController = [[OptionsViewController alloc] initWithNibName: @"OptionsViewController" bundle:nil];
    optionsController.total = total;
    optionsController.photo = false;
    [[AppDelegate rootController] pushViewController:optionsController animated:YES];
}

- (IBAction)onPhoto50:(id)sender
{
    [self photo: 50];    //TODO
}

- (IBAction)onPhoto100:(id)sender {
    [self photo: 100];
}

- (IBAction)onPhoto200:(id)sender {
    [self photo: 200];
}

- (IBAction)onPhoto500:(id)sender {
    [self photo: 500];
}

- (IBAction)onVideo5:(id)sender
{
    [self video: 5];    //TODO
}

- (IBAction)onVideo10:(id)sender
{
    [self video: 10];
}

- (IBAction)onVideo30:(id)sender
{
    [self video: 30];
}

- (IBAction)onVideo60:(id)sender
{
    [self video: 60];
}

- (IBAction)onShop:(id)sender
{
    [AppDelegate openShop];
}
@end

/*
@implementation UINavigationController (overrides)
- (BOOL)shouldAutorotate
{
    id currentViewController = self.topViewController;
    
    if ([currentViewController isKindOfClass:[CameraViewController class]])
        return YES;
    
    return NO;
}
@end
 */
