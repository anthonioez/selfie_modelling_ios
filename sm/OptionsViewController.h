//
//  OptionsViewController.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface OptionsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UISwitch *flashSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *frontSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rearSwitch;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property int total;
@property BOOL photo;

- (IBAction)onShop:(id)sender;
- (IBAction)onHome:(id)sender;

- (IBAction)onSwitchFlash:(id)sender;
- (IBAction)onSwitchFront:(id)sender;
- (IBAction)onSwitchRear:(id)sender;

- (IBAction)onStart:(id)sender;
@end
