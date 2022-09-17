//
//  CameraViewController.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/CGImageProperties.h>

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AssetsLibrary/AssetsLibrary.h"

@interface CameraViewController : UIViewController<GADInterstitialDelegate, AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property(nonatomic, strong) GADInterstitial *interstitial;

@property int count;
@property int total;
@property BOOL photo;

- (IBAction)onStop:(id)sender;
@end
