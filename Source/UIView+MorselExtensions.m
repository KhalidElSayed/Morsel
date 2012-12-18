//
//  UIView+MorselExtensions.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "UIView+MorselExtensions.h"

#import "NSLayoutConstraint+MorselExtensions.h"
#import "UIView+ConstraintConveniences.h"

#import <objc/runtime.h>

static void *kMorselID;

@implementation UIView (MorselExtensions)

- (NSString *)morselID
	{
	return(objc_getAssociatedObject(self, &kMorselID));
	}

- (void)setMorselID:(NSString *)inMorselID
	{
	objc_setAssociatedObject(self, &kMorselID, inMorselID, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}

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
