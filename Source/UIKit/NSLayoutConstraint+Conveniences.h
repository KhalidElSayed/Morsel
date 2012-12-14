//
//  NSLayoutConstraint+Conveniences.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Conveniences)

+ (NSArray *)constraintsForViews:(NSArray *)inViews alignedOnAttribute:(NSLayoutAttribute)inAttribute;
+ (NSArray *)constraintsForViews:(NSArray *)inViews distributed:(UILayoutConstraintAxis)inAxis;
@end
