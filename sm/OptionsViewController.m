//
//  OptionsViewController.m
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import "AppDelegate.h"
#import "OptionsViewController.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[Utils makeXibName:nibNameOrNil] bundle:nibBundleOrNil];
    if (self)
    {
        self.photo = true;
        self.total = 10;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    [self.flashSwitch setOn: [Settings getFlash]];
    [self.frontSwitch setOn: [Settings getCameraFront]];
    [self.rearSwitch setOn: ![Settings getCameraFront]];
    
    self.bannerView.adUnitID = ADMOB_BANNER_ID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setCamera: (BOOL) front state: (BOOL) state
{
    if(front)
        [self.frontSwitch setOn: state];
    else
        [self.rearSwitch setOn: !state];

    [Settings setCameraFront: state];
}

- (IBAction)onShop:(id)sender {
    
    [AppDelegate openShop];
}

- (IBAction)onHome:(id)sender {
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (IBAction)onSwitchFlash:(id)sender
{
    [Settings setFlash: self.flashSwitch.isOn];
}

- (IBAction)onSwitchFront:(id)sender
{
    [self setCamera: NO state: [self.frontSwitch isOn]];
}

- (IBAction)onSwitchRear:(id)sender
{
    [self setCamera: YES state: ![self.rearSwitch isOn]];
}

- (IBAction)onStart:(id)sender
{
    [[AppDelegate photos] removeAllObjects];
    
    CameraViewController *cameraController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    cameraController.photo = self.photo;
    cameraController.total = self.total;
    [[AppDelegate rootController] pushViewController:cameraController animated:YES];
}
@end
