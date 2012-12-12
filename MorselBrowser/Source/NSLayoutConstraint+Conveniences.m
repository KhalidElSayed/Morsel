//
//  NSLayoutConstraint+Conveniences.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "NSLayoutConstraint+Conveniences.h"

@implementation NSLayoutConstraint (Conveniences)

+ (NSArray *)constraintsForViews:(NSArray *)inViews alignedOnAttribute:(NSLayoutAttribute)inAttribute
	{
	NSParameterAssert(inViews.count > 0);
	NSMutableArray *theConstraints = [NSMutableArray array];
	UIView *theFirstView = inViews[0];
	for (UIView *theView in [inViews subarrayWithRange:(NSRange){ 1, inViews.count - 1 }])
		{
		NSLayoutConstraint *theConstraint = [NSLayoutConstraint constraintWithItem:theFirstView attribute:inAttribute relatedBy:NSLayoutRelationEqual toItem:theView attribute:inAttribute multiplier:1.0 constant:0.0];
		[theConstraints addObject:theConstraint];
		}
	return([theConstraints copy]);
	}

@end
