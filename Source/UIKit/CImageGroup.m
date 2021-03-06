//
//	CMorsel.h
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

#import "CImageGroup.h"

static NSString *nameSuffixForState(UIControlState inControlState);

@interface CImageGroup ()
@property (readonly, nonatomic, assign) BOOL resizable;
@end

#pragma mark -

@implementation CImageGroup

+ (CImageGroup *)imageGroupNamed:(NSString *)inName capInsets:(UIEdgeInsets)inInsets;
	{
	return([[self alloc] initWithName:inName insets:inInsets]);
	}

+ (CImageGroup *)imageGroupNamed:(NSString *)inName
	{
	return([[self alloc] initWithName:inName insets:(UIEdgeInsets){}]);
	}

- (id)initWithName:(NSString *)inName insets:(UIEdgeInsets)inInsets
    {
    if ((self = [super init]) != NULL)
        {
        _name = inName;
		_insets = inInsets;
        }
    return self;
    }

- (NSArray *)states
	{
	NSMutableArray *theStates = [NSMutableArray array];
	for (NSUInteger theState = 0; theState != 8; ++theState)
		{
		NSString *theImageName = [self imageNameForState:theState];
		UIImage *theImage = [UIImage imageNamed:theImageName];
		if (theImage != NULL)
			{
			[theStates addObject:@(theState)];
			}
		}
	return([theStates copy]);
	}

- (BOOL)resizable
	{
	return(UIEdgeInsetsEqualToEdgeInsets(self.insets, (UIEdgeInsets){}) == NO);
	}

#pragma mark -

- (NSString *)imageNameWithSuffix:(NSString *)inSuffix
	{
	NSString *theBaseName = [self.name stringByDeletingPathExtension];
	NSString *thePathExtension = [self.name pathExtension];
	NSString *theName = [[theBaseName stringByAppendingString:inSuffix] stringByAppendingPathExtension:thePathExtension];
	return(theName);
	}

- (NSString *)imageNameForState:(UIControlState)inControlState
	{
	NSString *theNameSuffix = nameSuffixForState(inControlState);
	NSString *theName = [self imageNameWithSuffix:theNameSuffix];
	return(theName);
	}

- (UIImage *)image
	{
	NSString *theImageName = self.name;
	UIImage *theImage = [UIImage imageNamed:theImageName];
	if (theImage == NULL)
		{
		theImageName = [self imageNameWithSuffix:@"Normal"];
		theImage = [UIImage imageNamed:theImageName];
		}
	return(theImage);
	}

- (UIImage *)imageForState:(UIControlState)inControlState
	{
	NSString *theName = [self imageNameForState:inControlState];

	UIImage *theImage = [UIImage imageNamed:theName];
	if (theImage == NULL)
		{
		NSLog(@"No image named %@ found for control state %d", self.name, inControlState);
		theImage = [UIImage imageNamed:self.name];
		}

	if (self.resizable == YES)
		{
		theImage = [theImage resizableImageWithCapInsets:self.insets];
		}

	return(theImage);
	}

- (void)enumerateImages:(void (^)(UIImage *image, UIControlState state))block;
	{
	NSInteger theCount = 0;
	for (NSUInteger theState = 0; theState != 8; ++theState)
		{
		NSString *theImageName = [self imageNameForState:theState];
		UIImage *theImage = [UIImage imageNamed:theImageName];

		if (theState == 0 && theImage == NULL)
			{
			theImageName = [self imageNameWithSuffix:@"Normal"];
			theImage = [UIImage imageNamed:theImageName];
			}

		if (theImage != NULL)
			{
			if (self.resizable == YES)
				{
				theImage = [theImage resizableImageWithCapInsets:self.insets];
				}
//			NSLog(@"%@", theImageName);
			theCount++;
			block(theImage, theState);
			}
		}
	if (theCount == 0)
		{
		NSLog(@"No images found for \"%@\", possible typo in image name?", self.name);
		}
	}

@end

#pragma mark -

static NSString *nameSuffixForState(UIControlState inControlState)
	{
	NSMutableArray *theAtoms = [NSMutableArray array];

	if (inControlState & UIControlStateHighlighted)
		{
		[theAtoms addObject:@"Highlighted"];
		}

	if (inControlState & UIControlStateDisabled)
		{
		[theAtoms addObject:@"Disabled"];
		}

	if (inControlState & UIControlStateSelected)
		{
		[theAtoms addObject:@"Selected"];
		}

	return([theAtoms componentsJoinedByString:@""]);
	}
