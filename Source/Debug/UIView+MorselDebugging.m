//
//  UIView+MorselDebugging.m
//  Morsel
//
//  Created by Jonathan Wight on 1/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "UIView+MorselDebugging.h"

#import "NSLayoutConstraint+DebugExtensions.h"
#import "UIView+MorselExtensions.h"

@implementation UIView (MorselDebugging)

- (void)dumpConstraints
	{
	NSMutableArray *theDescriptions = [NSMutableArray array];
	for (NSLayoutConstraint *theConstraint in [self recursiveConstraints])
		{
		[theDescriptions addObject:[theConstraint debugDescription]];
		}
	[theDescriptions sortUsingSelector:@selector(compare:)];
	NSLog(@"%@", [theDescriptions componentsJoinedByString:@"\n"]);
	}

@end
