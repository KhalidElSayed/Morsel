//
//  UIView+MorselExtensions.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "UIView+MorselExtensions.h"

#import "NSLayoutConstraint+MorselExtensions.h"
#import "UIView+MorselExtensions.h"

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

#pragma mark -

- (UILayoutPriority)horizontalContentHuggingPriority
	{
	return([self contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal]);
	}

- (void)setHorizontalContentHuggingPriority:(UILayoutPriority)priority
	{
	[self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisHorizontal];
	}

- (UILayoutPriority)verticalContentHuggingPriority
	{
	return([self contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical]);
	}

- (void)setVerticalContentHuggingPriority:(UILayoutPriority)priority
	{
	[self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisVertical];
	}

#pragma mark -

- (UILayoutPriority)horizontalContentCompressionResistancePriority
	{
	return([self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal]);
	}

- (void)setHorizontalContentCompressionResistancePriority:(UILayoutPriority)priority
	{
	[self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisHorizontal];
	}

- (UILayoutPriority)verticalContentCompressionResistancePriority
	{
	return([self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical]);
	}

- (void)setVerticalContentCompressionResistancePriority:(UILayoutPriority)priority
	{
	[self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisVertical];
	}

#pragma mark -

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

#pragma mark -

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
