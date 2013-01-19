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

+ (NSLayoutConstraint *)constraintWithRelationshipInString:(NSString *)inFormula views:(NSDictionary *)inViews;
	{
//	view_a.height = view_b.width
//	view_a.height = view_b.width * 100 + 10

	NSDictionary *theAttributes = @{
		@"left": @(NSLayoutAttributeLeft),
		@"right": @(NSLayoutAttributeRight),
		@"top": @(NSLayoutAttributeTop),
		@"bottom": @(NSLayoutAttributeBottom),
		@"leading": @(NSLayoutAttributeLeading),
		@"trailing": @(NSLayoutAttributeTrailing),
		@"width": @(NSLayoutAttributeWidth),
		@"height": @(NSLayoutAttributeHeight),
		@"center-x": @(NSLayoutAttributeCenterX),
		@"center-y": @(NSLayoutAttributeCenterY),
		@"baseline": @(NSLayoutAttributeBaseline),
		};
	NSDictionary *theRelations = @{
		@"<=": @(NSLayoutRelationLessThanOrEqual),
		@"=": @(NSLayoutRelationEqual),
		@"=?": @(NSLayoutRelationGreaterThanOrEqual),
		};

	NSString *theAttributesPattern = [[theAttributes allKeys] componentsJoinedByString:@"|"];
    NSString *theNumberPattern = @"-?\\d+(?:\\.\\d+)?";
	NSString *thePattern = [NSString stringWithFormat:@"^([a-z]\\w*)\\.(%@)(=|>=|<=)([a-z]\\w*)\\.(%@)(?:\\*(%@))?(?:(\\+|-)(%@))?", theAttributesPattern, theAttributesPattern, theNumberPattern, theNumberPattern];

	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:thePattern options:NSRegularExpressionCaseInsensitive error:&error];

	NSString *theFormula = [inFormula stringByReplacingOccurrencesOfString:@" " withString:@""];

	NSTextCheckingResult *theMatch = [regex firstMatchInString:theFormula options:0 range:(NSRange){ .length = theFormula.length }];
	NSAssert(theMatch != NULL, @"Relationship does not match expression.");

	NSString *theFirstObjectName = [theFormula substringWithRange:[theMatch rangeAtIndex:1]];
	id theFirstObject = inViews[theFirstObjectName];
	NSAssert(theFirstObject != NULL, @"Could not find object named %@", theFirstObjectName);

	NSString *theFirstAttributeName = [theFormula substringWithRange:[theMatch rangeAtIndex:2]];
	NSLayoutAttribute theFirstAttribute = [theAttributes[theFirstAttributeName] intValue];

	NSString *theRelationName = [theFormula substringWithRange:[theMatch rangeAtIndex:3]];
	NSLayoutRelation theRelation = [theRelations[theRelationName] intValue];

	NSString *theSecondObjectName = [theFormula substringWithRange:[theMatch rangeAtIndex:4]];
	id theSecondObject = inViews[theSecondObjectName];
	NSAssert(theSecondObject != NULL, @"Could not find object named %@", theSecondObjectName);

	NSString *theSecondAttributeName = [theFormula substringWithRange:[theMatch rangeAtIndex:5]];
	NSLayoutAttribute theSecondAttribute = [theAttributes[theSecondAttributeName] intValue];

	CGFloat theMultiplier = 1.0;
	if ([theMatch rangeAtIndex:6].location != NSNotFound)
		{
		NSString *theMultiplierString = [theFormula substringWithRange:[theMatch rangeAtIndex:6]];
		theMultiplier = [theMultiplierString floatValue];
		}

	CGFloat theConstant = 0.0;
	if ([theMatch rangeAtIndex:7].location != NSNotFound)
		{
		NSString *theSign = [theFormula substringWithRange:[theMatch rangeAtIndex:7]];

		NSString *theConstantString = [theFormula substringWithRange:[theMatch rangeAtIndex:8]];
		theConstant = [theConstantString floatValue];
        if ([theSign characterAtIndex:0] == '-')
            {
            theConstant *= -1.0;
            }
		}

	NSLayoutConstraint *theConstraint = [NSLayoutConstraint constraintWithItem:theFirstObject attribute:theFirstAttribute relatedBy:theRelation toItem:theSecondObject attribute:theSecondAttribute multiplier:theMultiplier constant:theConstant];

	return(theConstraint);
	}

@end
