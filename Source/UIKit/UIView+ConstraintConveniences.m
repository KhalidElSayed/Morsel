//
//  UIView+ConstraintConveniences.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/13/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "UIView+ConstraintConveniences.h"

@implementation UIView (ConstraintConveniences)

- (NSArray *)recursiveConstraints
	{
	NSMutableArray *theConstaints = [NSMutableArray array];

	[theConstaints addObjectsFromArray:self.constraints];
	for (UIView *theView in self.subviews)
		{
		[theConstaints addObjectsFromArray:[theView recursiveConstraints]];
		}
	return(theConstaints);
	}

- (NSArray *)recursiveConstraintsMatchingPredicate:(NSPredicate *)inPredicate
	{
	NSMutableArray *theConstaints = [NSMutableArray array];

	[theConstaints addObjectsFromArray:[self.constraints filteredArrayUsingPredicate:inPredicate]];
	for (UIView *theView in self.subviews)
		{
		[theConstaints addObjectsFromArray:[theView recursiveConstraintsMatchingPredicate:inPredicate]];
		}
	return(theConstaints);
	}


- (NSLayoutConstraint *)constantWidthConstraint
	{
	NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"firstItem == %@ && firstAttribute == %@ && relation == %@ && secondItem == NULL && multiplier == 1.0", self, @(NSLayoutAttributeWidth), @(NSLayoutRelationEqual)];
	NSArray *theConstraints = [self.superview recursiveConstraintsMatchingPredicate:thePredicate];
	return([theConstraints lastObject]);
	}

- (NSLayoutConstraint *)constantHeightConstraint
	{
	NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"firstItem == %@ && firstAttribute == %@ && relation == %@ && secondItem == NULL && multiplier == 1.0", self, @(NSLayoutAttributeHeight), @(NSLayoutRelationEqual)];
	NSArray *theConstraints = [self.superview recursiveConstraintsMatchingPredicate:thePredicate];
	return([theConstraints lastObject]);
	}

@end
