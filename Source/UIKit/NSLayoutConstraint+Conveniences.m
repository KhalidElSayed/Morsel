//
//	NSLayoutConstraint+Conveniences.m
//	Morsel
//
//	Created by Jonathan Wight on 12/8/12.
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
