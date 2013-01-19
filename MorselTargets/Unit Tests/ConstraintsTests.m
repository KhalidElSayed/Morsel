//
//  ConstraintsTests.m
//  Morsel
//
//  Created by Jonathan Wight on 1/19/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "ConstraintsTests.h"

#import "NSLayoutConstraint+Conveniences.h"

@implementation ConstraintsTests

- (void)test1
	{
    UIView *theParentView = [[UIView alloc] initWithFrame:CGRectZero];

    UIView *theFirstView = [[UIView alloc] initWithFrame:CGRectZero];
    [theParentView addSubview:theFirstView];

    UIView *theSecondView = [[UIView alloc] initWithFrame:CGRectZero];
    [theParentView addSubview:theSecondView];

    NSDictionary *theViews = @{
        @"first": theFirstView,
        @"second": theSecondView,
        };

    NSLayoutConstraint *theConstraint = NULL;

    theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:@"first.top = second.top" views:theViews];
    STAssertEquals(theConstraint.multiplier, 1.0f, NULL);
    STAssertEquals(theConstraint.constant, 0.0f, NULL);

    theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:@"first.top = second.top * 1.0 + 100" views:theViews];
    STAssertEquals(theConstraint.multiplier, 1.0f, NULL);
    STAssertEquals(theConstraint.constant, 100.0f, NULL);

    theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:@"first.top = second.top * -1.0 + -100" views:theViews];
    STAssertEquals(theConstraint.multiplier, -1.0f, NULL);
    STAssertEquals(theConstraint.constant, -100.0f, NULL);

    theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:@"first.top = second.top * 3.0" views:theViews];
    STAssertEquals(theConstraint.multiplier, 3.0f, NULL);
    STAssertEquals(theConstraint.constant, 0.0f, NULL);

    theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:@"first.top = second.top + 10.0" views:theViews];
    STAssertEquals(theConstraint.multiplier, 1.0f, NULL);
    STAssertEquals(theConstraint.constant, 10.0f, NULL);

    theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:@"first.top = second.top - 10.0" views:theViews];
    STAssertEquals(theConstraint.multiplier, 1.0f, NULL);
    STAssertEquals(theConstraint.constant, -10.0f, NULL);
    }

@end
