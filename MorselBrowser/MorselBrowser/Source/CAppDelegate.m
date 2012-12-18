//
//  CAppDelegate.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CAppDelegate.h"

#import "CTestLoginViewController.h"

@implementation CAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
    return(YES);
	}

- (IBAction)test:(id)sender
	{
	CTestLoginViewController *theViewController = [[CTestLoginViewController alloc] init];
	[self.window.rootViewController presentViewController:theViewController animated:YES completion:NULL];
	}

@end
