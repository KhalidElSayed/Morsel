//
//  UIView+Conveniences.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "UIView+Conveniences.h"

@implementation UIView (Conveniences)

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

@end
