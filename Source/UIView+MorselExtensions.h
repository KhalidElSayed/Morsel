//
//  UIView+MorselExtensions.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MorselExtensions)

@property (readwrite, nonatomic, copy) NSString *morselID;

@property (readwrite, nonatomic, assign) UILayoutPriority horizontalContentHuggingPriority;
@property (readwrite, nonatomic, assign) UILayoutPriority verticalContentHuggingPriority;

@property (readwrite, nonatomic, assign) UILayoutPriority horizontalContentCompressionResistancePriority;
@property (readwrite, nonatomic, assign) UILayoutPriority verticalContentCompressionResistancePriority;

- (NSArray *)recursiveConstraints;
- (NSArray *)recursiveConstraintsMatchingPredicate:(NSPredicate *)inPredicate;
- (NSLayoutConstraint *)constantWidthConstraint;
- (NSLayoutConstraint *)constantHeightConstraint;

- (void)dumpConstraints;

@end
