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
		NSLayoutConstraint *theConstraint = [NSLayoutConstraint constraintWithItem:theView attribute:inAttribute relatedBy:NSLayoutRelationEqual toItem:theFirstView attribute:inAttribute multiplier:1.0 constant:0.0];
		[theConstraints addObject:theConstraint];
		}
	return([theConstraints copy]);
	}

+ (NSArray *)constraintsForViews:(NSArray *)inViews distributed:(UILayoutConstraintAxis)inAxis
	{
	NSParameterAssert(inViews.count > 0);
	NSMutableArray *theConstraints = [NSMutableArray array];
	UIView *theLastView = inViews[0];
	for (UIView *theView in [inViews subarrayWithRange:(NSRange){ 1, inViews.count - 1 }])
		{
		NSLayoutConstraint *theConstraint = NULL;
		if (inAxis == UILayoutConstraintAxisVertical)
			{
			theConstraint = [NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:theLastView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
			}
		else
			{
			theConstraint = [NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:theLastView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
			}
		[theConstraints addObject:theConstraint];
		theLastView = theView;
		}
	return([theConstraints copy]);
	}

@end
