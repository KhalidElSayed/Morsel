//
//  CAppDelegate.m
//  MorselMinimal
//
//  Created by Jonathan Wight on 1/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CAppDelegate.h"

#import "CViewController.h"

@implementation CAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CViewController alloc] init];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return(YES);
    }

@end
