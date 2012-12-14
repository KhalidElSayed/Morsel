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


#pragma mark -

- (NSString *)debugDescription
	{
	NSDictionary *theRelations = @{
		@(NSLayoutRelationLessThanOrEqual): @"<= (-1)",
		@(NSLayoutRelationEqual): @"= (0)",
		@(NSLayoutRelationGreaterThanOrEqual): @">= (1)",
		};
	NSDictionary *theAttributes = @{
		@(NSLayoutAttributeLeft): [NSString stringWithFormat:@"Left (%d)", NSLayoutAttributeLeft],
		@(NSLayoutAttributeRight): [NSString stringWithFormat:@"Right (%d)", NSLayoutAttributeRight],
		@(NSLayoutAttributeTop): [NSString stringWithFormat:@"Top (%d)", NSLayoutAttributeTop],
		@(NSLayoutAttributeBottom): [NSString stringWithFormat:@"Bottom (%d)", NSLayoutAttributeBottom],
		@(NSLayoutAttributeLeading): [NSString stringWithFormat:@"Leading (%d)", NSLayoutAttributeLeading],
		@(NSLayoutAttributeTrailing): [NSString stringWithFormat:@"Trailing (%d)", NSLayoutAttributeTrailing],
		@(NSLayoutAttributeWidth): [NSString stringWithFormat:@"Width (%d)", NSLayoutAttributeWidth],
		@(NSLayoutAttributeHeight): [NSString stringWithFormat:@"Height (%d)", NSLayoutAttributeHeight],
		@(NSLayoutAttributeCenterX): [NSString stringWithFormat:@"CenterX (%d)", NSLayoutAttributeCenterX],
		@(NSLayoutAttributeCenterY): [NSString stringWithFormat:@"CenterY (%d)", NSLayoutAttributeCenterY],
		@(NSLayoutAttributeBaseline): [NSString stringWithFormat:@"Baseline (%d)", NSLayoutAttributeBaseline],
		@(NSLayoutAttributeNotAnAttribute): [NSString stringWithFormat:@"NotAnAttribute (%d)", NSLayoutAttributeNotAnAttribute],
		};

	NSDictionary *theProperties = @{
		@"priority": @(self.priority),
		@"shouldBeArchived": @(self.shouldBeArchived),
		@"firstItem": self.firstItem ?: [NSNull null],
		@"firstAttribute": theAttributes[@(self.firstAttribute)],
		@"relation": theRelations[@(self.relation)],
		@"secondItem": self.secondItem ?: [NSNull null],
		@"secondAttribute": theAttributes[@(self.secondAttribute)],
		@"constant": @(self.constant),
		@"multiplier": @(self.multiplier),
		};

    return([NSString stringWithFormat:@"%@: %@", [super description], theProperties]);	
	}


@end
