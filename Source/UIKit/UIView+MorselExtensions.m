//
//	UIView+MorselExtensions.m
//	Morsel
//
//	Created by Jonathan Wight on 12/17/12.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "UIView+MorselExtensions.h"

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

@end
