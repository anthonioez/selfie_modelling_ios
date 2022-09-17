//
//  Utils.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AVFoundation/AVFoundation.h>

#import <CommonCrypto/CommonDigest.h>


@interface Utils : NSObject

+ (void) message:(NSString *)title :(NSString *)message;

+ (NSString *) makeXibName:(NSString *)resourceName;

+ (NSString*) getSHA1:(NSString*)input;

+ (NSString *) imageOrientName: (UIImageOrientation) orient;
+ (NSString *) deviceOrientName: (UIDeviceOrientation) orient;
+ (UIImageOrientation) deviceToImageOrientation:(UIDeviceOrientation)device image:(UIImageOrientation)image;
+(AVCaptureVideoOrientation) deviceToCaptureOrientation: (UIDeviceOrientation)deviceOrientation;

+ (AVCaptureDevice*)selectCamera: (AVCaptureDevicePosition) cam;

+ (BOOL) deleteFile: (NSString *)path;
@end
