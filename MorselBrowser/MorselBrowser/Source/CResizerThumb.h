//
//  CResizerThumb.h
//  CoreText
//
//  Created by Jonathan Wight on 10/28/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CResizerThumb : UIView

@property (readwrite, nonatomic, assign) CGSize minimumSize;
@property (readwrite, nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;
@property (readwrite, nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@end
