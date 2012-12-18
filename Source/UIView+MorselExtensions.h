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

- (void)dumpConstraints;

@end
