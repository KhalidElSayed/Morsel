//
//  CAppDelegate.m
//  MorselMinimal
//
//  Created by Jonathan Wight on 1/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CAppDelegate.h"

#import "CMorsel.h"

@implementation CAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSError *theError = NULL;
    CMorsel *theMorsel = [[CMorsel alloc] initWithName:@"UI" bundle:NULL error:&theError];
    UIViewController *theViewController = [theMorsel instantiateWithOwner:NULL options:NULL error:&theError][@"view_controller"];
    NSLog(@"%@", theError);
	self.window.rootViewController = theViewController;
    [self.window makeKeyAndVisible];
    return(YES);
    }

@end
