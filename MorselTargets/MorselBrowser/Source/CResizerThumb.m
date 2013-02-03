//
//	CResizerThumb.m
//	Morsel
//
//	Created by Jonathan Wight on 10/28/11.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "CResizerThumb.h"

#import <QuartzCore/QuartzCore.h>

@interface CResizerThumb()
@property (readwrite, nonatomic, assign) CGSize thumbSize;
@property (readwrite, nonatomic, assign) CGSize originalSize;
@property (readwrite, nonatomic, assign) CGPoint touchBeganLocation;
@end

#pragma mark -

@implementation CResizerThumb

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [super initWithCoder:inCoder]) != NULL)
        {
		UIImageView *theImageView = [[UIImageView alloc] initWithFrame:(CGRect){ .size = { 16, 16 } }];
		theImageView.image = [UIImage imageNamed:@"Thumb.png"];
		[self addSubview:theImageView];
        }
    return(self);
    }

- (id)initWithFrame:(CGRect)frame
    {
    if ((self = [super initWithFrame:frame]) != NULL)
        {
		UIImageView *theImageView = [[UIImageView alloc] initWithFrame:(CGRect){ .size = { 16, 16 } }];
		theImageView.image = [UIImage imageNamed:@"Thumb.png"];
		[self addSubview:theImageView];
        }
    return(self);
    }

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
    self.originalSize = self.superview.frame.size;

    UITouch *theTouch = [touches anyObject];
    CGPoint theLocation = [theTouch locationInView:self];
    self.touchBeganLocation = [self convertPoint:theLocation toView:self.superview];
    }

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
    {
    UITouch *theTouch = [touches anyObject];
    CGPoint theLocation = [self convertPoint:[theTouch locationInView:self] toView:self.superview];

//    self.superview.frame = (CGRect){
//        .origin = self.superview.frame.origin,
//        .size = {
//            .width = MAX(self.originalSize.width + (theLocation.x - self.touchBeganLocation.x), self.minimumSize.width),
//            .height = MAX(self.originalSize.height + (theLocation.y - self.touchBeganLocation.y), self.minimumSize.height),
//            },
//        };

	self.widthConstraint.constant = MAX(self.originalSize.width + (theLocation.x - self.touchBeganLocation.x), self.minimumSize.width);
	self.heightConstraint.constant = MAX(self.originalSize.height + (theLocation.y - self.touchBeganLocation.y), self.minimumSize.height);
    }
    
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
    {
    }
    
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
    {
    }

@end
