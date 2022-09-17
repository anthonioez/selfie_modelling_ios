//
//  AppDelegate.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "MainViewController.h"
#import "OptionsViewController.h"
#import "FinalViewController.h"
#import "CameraViewController.h"
#import "Utils.h"
#import "Settings.h"

#define COUNT_WAIT  10   //TODO

#define ADMOB_BANNER_ID         @""
#define ADMOB_INTERS_ID         @""
#define SHOP_URL                @"https://shop.selfiemodeling.com"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (UINavigationController *)rootController;
+ (NSMutableArray *)photos;
+ (NSString *) path;
+ (void) resetSession;

+ (void) openShop;

@end

