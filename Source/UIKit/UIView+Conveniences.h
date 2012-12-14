//
//  UIView+Conveniences.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Conveniences)

@property (readwrite, nonatomic, assign) UILayoutPriority horizontalContentHuggingPriority;
@property (readwrite, nonatomic, assign) UILayoutPriority verticalContentHuggingPriority;

@property (readwrite, nonatomic, assign) UILayoutPriority horizontalContentCompressionResistancePriority;
@property (readwrite, nonatomic, assign) UILayoutPriority verticalContentCompressionResistancePriority;


@end
