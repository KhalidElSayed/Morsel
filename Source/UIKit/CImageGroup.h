//
//	CImageGroup.h
//	Morsel
//
//	Created by Jonathan Wight on 12/5/12.
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

#import <UIKit/UIKit.h>

@interface CImageGroup : NSObject

@property (readonly, nonatomic, strong) NSString *name;
@property (readonly, nonatomic, strong) NSArray *states;
@property (readonly, nonatomic, assign) UIEdgeInsets insets;

/**
 * Create an image group.
 *
 * Image groups consist of all files in the main bundle that match the following pseudo-regex: <image name>(Highlighted)?(Disabled)?(Selected)?(@2x)?.(png|jpg|*)
 * All images are made resizable via the cap insets (use a 0 cap insets if you don't want resizable images). Therefore all images must share the same cap insets. Question: are different insets per image state necessary?
 */
+ (CImageGroup *)imageGroupNamed:(NSString *)inName capInsets:(UIEdgeInsets)inInsets;

/**
 * Load an image group with resizable cap insets loaded via a specification file. See UIImage+ResizableConveniences.h
 */
+ (CImageGroup *)imageGroupNamed:(NSString *)inName;

/**
 * Designated initialiser.
 */
- (id)initWithName:(NSString *)inName insets:(UIEdgeInsets)inInsets;

- (UIImage *)image;

/**
 * Return a single (possibly resizable) image for a control state. You probably should be using -[CImageGroup enumerateImages:] instead.
 */
- (UIImage *)imageForState:(UIControlState)inControlState;

/**
 * Enumerate through all image states in a group calling the block for each one.
 * This is the main work method for Image Groups and can be used to quickly set a control's image (or background image) for all provided image states.
 *
 * Example:
 * [someImageGroup enumerateImages:^(UIImage *image, UIControlState state) {
 *     [someControl setImage:image forState:state];
 *     }];
 */
- (void)enumerateImages:(void (^)(UIImage *image, UIControlState state))block;

@end
