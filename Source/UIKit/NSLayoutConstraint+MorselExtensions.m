//
//  NSLayoutConstraint+MorselExtensions.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "NSLayoutConstraint+MorselExtensions.h"

#import "UIView+MorselExtensions.h"

@implementation NSLayoutConstraint (MorselExtensions)

- (NSString *)debugDescription
	{
	return([self shortDebugDescription]);
	}

- (NSString *)longDebugDescription
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
		@"firstItem": self.firstItem ? ([self.firstItem morselID] ?: self.firstItem) : [NSNull null],
		@"firstAttribute": theAttributes[@(self.firstAttribute)],
		@"relation": theRelations[@(self.relation)],
		@"secondItem": self.secondItem ? ([self.secondItem morselID] ?: self.secondItem) : [NSNull null],
		@"secondAttribute": theAttributes[@(self.secondAttribute)],
		@"constant": @(self.constant),
		@"multiplier": @(self.multiplier),
		};

    return([NSString stringWithFormat:@"%@: %@", [super description], theProperties]);
	}

- (NSString *)shortDebugDescription
	{
	NSDictionary *theRelations = @{
		@(NSLayoutRelationLessThanOrEqual): @"<=",
		@(NSLayoutRelationEqual): @"=",
		@(NSLayoutRelationGreaterThanOrEqual): @">=",
		};
	NSDictionary *theAttributes = @{
		@(NSLayoutAttributeLeft): [NSString stringWithFormat:@"Left"],
		@(NSLayoutAttributeRight): [NSString stringWithFormat:@"Right"],
		@(NSLayoutAttributeTop): [NSString stringWithFormat:@"Top"],
		@(NSLayoutAttributeBottom): [NSString stringWithFormat:@"Bottom"],
		@(NSLayoutAttributeLeading): [NSString stringWithFormat:@"Leading"],
		@(NSLayoutAttributeTrailing): [NSString stringWithFormat:@"Trailing"],
		@(NSLayoutAttributeWidth): [NSString stringWithFormat:@"Width"],
		@(NSLayoutAttributeHeight): [NSString stringWithFormat:@"Height"],
		@(NSLayoutAttributeCenterX): [NSString stringWithFormat:@"CenterX"],
		@(NSLayoutAttributeCenterY): [NSString stringWithFormat:@"CenterY"],
		@(NSLayoutAttributeBaseline): [NSString stringWithFormat:@"Baseline"],
		@(NSLayoutAttributeNotAnAttribute): [NSString stringWithFormat:@"NotAnAttribute"],
		};

	NSMutableArray *theComponents = [NSMutableArray array];



    [theComponents addObject:[NSString stringWithFormat:@"%@.%@",
		self.firstItem ? ([self.firstItem morselID] ?: self.firstItem) : [NSNull null],
		theAttributes[@(self.firstAttribute)]
		]];

	[theComponents addObject:theRelations[@(self.relation)]];

	if (self.secondItem != NULL)
		{
		[theComponents addObject:[NSString stringWithFormat:@"%@.%@",
			self.secondItem ? ([self.secondItem morselID] ?: self.secondItem) : [NSNull null],
			theAttributes[@(self.secondAttribute)]
			]];
		}

	if (self.multiplier != 1.0)
		{
		[theComponents addObject:[NSString stringWithFormat:@"* %g", self.multiplier]];
		}

	if (self.constant != 0.0)
		{
		[theComponents addObject:[NSString stringWithFormat:@"+ %g", self.constant]];
		}


	return([theComponents componentsJoinedByString:@" "]);
	}


@end
