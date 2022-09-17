//
//  Settings.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SETTING_FLASH           @"flash"
#define SETTING_CAMERA          @"camera"

@interface Settings : NSObject

+ (void) setFlash:(BOOL)state;
+ (BOOL) getFlash;

+ (void) setCameraFront:(BOOL)state;
+ (BOOL) getCameraFront;
@end
