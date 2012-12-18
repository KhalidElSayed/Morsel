//
//  UIView+ConstraintConveniences.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/13/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ConstraintConveniences)

- (NSArray *)recursiveConstraints;
- (NSArray *)recursiveConstraintsMatchingPredicate:(NSPredicate *)inPredicate;
- (NSLayoutConstraint *)constantWidthConstraint;
- (NSLayoutConstraint *)constantHeightConstraint;

@end
