//
//  Settings.m
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import "Settings.h"


@implementation Settings
+ (void) setFlash:(BOOL)state
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:state] forKey:SETTING_FLASH];
}

+ (BOOL) getFlash
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *data = [defaults valueForKey:SETTING_FLASH];
    if(data == nil)
        return true;
    else
        return [data boolValue];
}

+ (void) setCameraFront:(BOOL)state
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:state] forKey:SETTING_CAMERA];
}

+ (BOOL) getCameraFront
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *data = [defaults valueForKey:SETTING_CAMERA];
    if(data == nil)
        return true;
    else
        return [data boolValue];
}


@end
