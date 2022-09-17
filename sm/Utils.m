//
//  Utils.m
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void) message:(NSString *)title :(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

+ (NSString *) makeXibName:(NSString *)resourceName
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        resourceName = [resourceName stringByAppendingString:@"~ipad"];
    else
        resourceName = [resourceName stringByAppendingString:@"~iphone"];
    
    return resourceName;
}

+(NSString*) getSHA1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

+ (NSString *) imageOrientName: (UIImageOrientation) orient
{
    switch (orient) {
        case UIImageOrientationUp:
            return @"up";               // default orientation
        case UIImageOrientationDown:
            return @"down";             // 180 deg rotation
        case UIImageOrientationLeft:
            return @"left";             // 90 deg CCW
        case UIImageOrientationRight:
            return @"right";            // 90 deg CW
        case UIImageOrientationUpMirrored:
            return @"up mirrored";      // as above but image mirrored along other axis. horizontal flip
        case UIImageOrientationDownMirrored:
            return @"down mirrored";    // horizontal flip
        case UIImageOrientationLeftMirrored:
            return @"left mirrored";    // vertical flip
        case UIImageOrientationRightMirrored:
            return @"right mirrored";   // vertical flip
        default:
            return @"unknown";
    }
}

// return the UIImageOrientation needed for an image captured with a specific deviceOrientation
+ (UIImageOrientation) deviceToImageOrientation:(UIDeviceOrientation)device image:(UIImageOrientation)image
{
    UIImageOrientation orientation;
    switch (device)
    {
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIImageOrientationLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orientation = UIImageOrientationDown;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationPortrait:
        default:
            orientation = UIImageOrientationRight;
            break;
    }
    
    orientation = image;
    return orientation;
}

+ (NSString *) deviceOrientName: (UIDeviceOrientation) orient
{
    switch (orient) {
        case UIDeviceOrientationPortrait:
            return @"portrait";                 // Device oriented vertically, home button on the bottom
        case UIDeviceOrientationPortraitUpsideDown:
            return @"portrait upsidedown";      // Device oriented vertically, home button on the top
        case UIDeviceOrientationLandscapeLeft:
            return @"landscape left";           // Device oriented horizontally, home button on the right
        case UIDeviceOrientationLandscapeRight:
            return @"landscape right";          // Device oriented horizontally, home button on the left
        case UIDeviceOrientationFaceUp:
            return @"face up";                  // Device oriented flat, face up
        case UIDeviceOrientationFaceDown:
            return @"face down";                // Device oriented flat, face down
        default:
            return @"unknown";
    }
}

+(AVCaptureVideoOrientation) deviceToCaptureOrientation: (UIDeviceOrientation)deviceOrientation
{
    if (deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return AVCaptureVideoOrientationPortraitUpsideDown;
    else if (deviceOrientation == UIInterfaceOrientationPortrait)
        return AVCaptureVideoOrientationPortrait;
    else if (deviceOrientation == UIInterfaceOrientationLandscapeLeft)
        return AVCaptureVideoOrientationLandscapeLeft;
    else
        return AVCaptureVideoOrientationLandscapeRight;
}

+ (AVCaptureDevice*)selectCamera: (AVCaptureDevicePosition) cam
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *dev in devices)
    {
        if ([dev position] == cam)
        {
            return dev;
        }
    }
    return nil;
}

+ (BOOL) deleteFile: (NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        NSError *error;
        return [fileManager removeItemAtPath:path error:&error];
    }

    return false;
}


@end

