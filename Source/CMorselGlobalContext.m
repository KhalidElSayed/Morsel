//
//  CMorselGlobalContext.m
//  Morsel
//
//  Created by Jonathan Wight on 2/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CMorselGlobalContext.h"

#import "CTypeConverter.h"
#import "MorselSupport.h"
#import "MorselAsserts.h"

#import "CTypeConverter.h"
#import "CYAMLDeserializer.h"
#import "CColorConverter.h"
#import "CImageGroup.h"
#import "CMorselContext.h"

@implementation CMorselGlobalContext

- (BOOL)load:(NSError **)outError
    {
    if ([super load:outError] == NO)
        {
        return(NO);
        }

	__weak __typeof(self) weak_self = self;

	// #########################################################################

	// NSString -> NSURL
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[NSURL class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		return([NSURL URLWithString:inValue]);
		}];

	// NSString -> UIColor
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[UIColor class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		return([UIColor colorWithString:inValue error:outError_]);
		}];

	// NSDictionary -> UIFont
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[UIFont class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		UIFont *theFont = [UIFont fontWithName:inValue[@"name"] size:[inValue[@"size"] floatValue]];
		return(theFont);
		}];

	// NSString -> UIImage
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[UIImage class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		return([UIImage imageNamed:inValue]);
		}];

	// NSDictionary -> UIImage
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[UIImage class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		UIImage *theImage = [UIImage imageNamed:inValue[@"name"]];
		NSDictionary *theCapInsetsDictionary = inValue[@"capInsets"];
		if (theCapInsetsDictionary)
			{
			UIEdgeInsets theCapInsets;
			theCapInsets.left = [theCapInsetsDictionary[@"left"] floatValue];
			theCapInsets.right = [theCapInsetsDictionary[@"right"] floatValue];
			theCapInsets.top = [theCapInsetsDictionary[@"top"] floatValue];
			theCapInsets.bottom = [theCapInsetsDictionary[@"bottom"] floatValue];
			theImage = [theImage resizableImageWithCapInsets:theCapInsets];
			}

		return(theImage);
		}];

	// NSString -> CImageGroup
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[CImageGroup class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		return([CImageGroup imageGroupNamed:inValue]);
		}];

	// NSDictionary -> CImageGroup
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[CImageGroup class] block:^id(id inValue, NSError *__autoreleasing *outError_) {
		UIEdgeInsets theCapInsets;
		NSDictionary *theCapInsetsDictionary = inValue[@"capInsets"];
		if (theCapInsetsDictionary)
			{
			theCapInsets.left = [theCapInsetsDictionary[@"left"] floatValue];
			theCapInsets.right = [theCapInsetsDictionary[@"right"] floatValue];
			theCapInsets.top = [theCapInsetsDictionary[@"top"] floatValue];
			theCapInsets.bottom = [theCapInsetsDictionary[@"bottom"] floatValue];
			}

		CImageGroup *theImageGroup = [CImageGroup imageGroupNamed:inValue[@"name"] capInsets:theCapInsets];
		return(theImageGroup);
		}];


	// NSDictionary -> CGPoint
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationType:@"struct:CGPoint" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		CGPoint thePoint = {
			.x = [inValue[@"x"] floatValue],
			.y = [inValue[@"y"] floatValue],
			};
		return([NSValue valueWithCGPoint:thePoint]);
		}];

	// NSArray -> CGPoint
	[self.typeConverter addConverterForSourceClass:[NSArray class] destinationType:@"struct:CGPoint" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		CGPoint thePoint = {
			.x = [inValue[0] floatValue],
			.y = [inValue[1] floatValue],
			};
		return([NSValue valueWithCGPoint:thePoint]);
		}];

	// NSDictionary -> CGSize
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationType:@"struct:CGSize" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		CGSize theSize = {
			.width = [inValue[@"width"] floatValue],
			.height = [inValue[@"height"] floatValue],
			};
		return([NSValue valueWithCGSize:theSize]);
		}];

	// NSArray -> CGSize
	[self.typeConverter addConverterForSourceClass:[NSArray class] destinationType:@"struct:CGSize" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		CGSize theSize = {
			.width = [inValue[0] floatValue],
			.height = [inValue[1] floatValue],
			};
		return([NSValue valueWithCGSize:theSize]);
		}];

	// UIColor -> CGColor
	[self.typeConverter addConverterForSourceClass:[UIColor class] destinationType:@"special:CGColor" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		UIColor *theColor = AssertCast_(UIColor, inValue);
		return((__bridge id)theColor.CGColor);
		}];

	// NSString -> CGColor
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationType:@"special:CGColor" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		UIColor *theColor = [weak_self.typeConverter objectOfClass:[UIColor class] withObject:inValue error:outError_];
		return((__bridge id)theColor.CGColor);
		}];

	// NSDictionary -> UIEdgeInsets
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationType:@"struct:UIEdgeInsets" block:^id(id inValue, NSError *__autoreleasing *outError_) {
		UIEdgeInsets theEdgeInsets = {
			.left = [inValue[@"left"] floatValue],
			.right = [inValue[@"right"] floatValue],
			.top = [inValue[@"top"] floatValue],
			.bottom = [inValue[@"bottom"] floatValue],
			};
		return([NSValue valueWithUIEdgeInsets:theEdgeInsets]);
		}];


	// #########################################################################

	// UIView.size
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"position"] block: ^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIView *theView = AssertCast_(UIView, object);

		NSValue *thePointValue = [weak_self.typeConverter objectOfType:@"struct:CGPoint" withObject:specification error:outError_];
		if (thePointValue == NULL)
			{
			return(NO);
			}
		CGPoint thePoint = [thePointValue CGPointValue];

		if (theView.translatesAutoresizingMaskIntoConstraints == YES)
			{
			CGRect theFrame = theView.frame;
			theFrame.origin = thePoint;
			theView.frame = theFrame;
			}
		else
			{
			[theView.superview addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:theView.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:thePoint.x]];
			[theView.superview addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:theView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:thePoint.y]];
			}

		return(YES);
		}];

	// UIView.size
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"size"] block: ^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIView *theView = AssertCast_(UIView, object);

		NSValue *theSizeValue = [weak_self.typeConverter objectOfType:@"struct:CGSize" withObject:specification error:outError_];
		if (theSizeValue == NULL)
			{
			return(NO);
			}
		CGSize theSize = [theSizeValue CGSizeValue];

		if (theView.translatesAutoresizingMaskIntoConstraints == YES)
			{
			CGRect theFrame = theView.frame;
			theFrame.size = theSize;
			theView.frame = theFrame;
			}
		else
			{
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:theSize.width]];
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:theSize.height]];
			}

		return(YES);
		}];

	// UIView.width
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"width"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIView *theView = AssertCast_(UIView, object);

		CGFloat theScalar = [specification floatValue];

		if (theView.translatesAutoresizingMaskIntoConstraints == YES)
			{
			CGRect theFrame = theView.frame;
			theFrame.size.width = theScalar;
			theView.frame = theFrame;
			}
		else
			{
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:theScalar]];
			}
		return(YES);
		}];

	// UIView.height
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"height"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIView *theView = AssertCast_(UIView, object);

		CGFloat theScalar = [specification floatValue];

		if (theView.translatesAutoresizingMaskIntoConstraints == YES)
			{
			CGRect theFrame = theView.frame;
			theFrame.size.height = theScalar;
			theView.frame = theFrame;
			}
		else
			{
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:theScalar]];
			}
		return(YES);
		}];

	// UIView.edge-constraints
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"edge-constraints"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIView *theView = AssertCast_(UIView, object);
		UIView *theSuperview = theView.superview;
		NSDictionary *theDictionary = AssertCast_(NSDictionary, specification);

		if (theDictionary[@"left"])
			{
			CGFloat theScalar = [theDictionary[@"left"] floatValue];
			[theView.superview addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:theSuperview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:theScalar]];
			}
		if (theDictionary[@"right"])
			{
			CGFloat theScalar = -[theDictionary[@"right"] floatValue];
			[theView.superview addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:theSuperview attribute:NSLayoutAttributeRight multiplier:1.0 constant:theScalar]];
			}
		if (theDictionary[@"top"])
			{
			CGFloat theScalar = [theDictionary[@"top"] floatValue];
			[theView.superview addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:theSuperview attribute:NSLayoutAttributeTop multiplier:1.0 constant:theScalar]];
			}
		if (theDictionary[@"bottom"])
			{
			CGFloat theScalar = -[theDictionary[@"bottom"] floatValue];
			[theView.superview addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:theSuperview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:theScalar]];
			}
		return(YES);
		}];

	// UIButton.title
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"title"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		[(UIButton *)object setTitle:specification forState:UIControlStateNormal];
		return(YES);
		}];

	// UIButton.backgroundImage
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"backgroundImage"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		CImageGroup *theImageGroup = [weak_self.typeConverter objectOfClass:[CImageGroup class] withObject:specification error:outError_];
		UIButton *theButton = AssertCast_(UIButton, object);
		[theImageGroup enumerateImages:^(UIImage *image, UIControlState state) {
			[theButton setBackgroundImage:image forState:state];
			}];
		return(YES);
		}];

	// UIButton.image
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"image"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIImage *theImage = [weak_self.typeConverter objectOfClass:[UIImage class] withObject:specification error:outError_];
		UIButton *theButton = AssertCast_(UIButton, object);
		[theButton setImage:theImage forState:UIControlStateNormal];
		return(YES);
		}];

	// UIButton.titleColor
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"titleColor"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {
		UIColor *theColor = [weak_self.typeConverter objectOfClass:[UIColor class] withObject:specification error:outError_];
		UIButton *theButton = AssertCast_(UIButton, object);
		[theButton setTitleColor:theColor forState:UIControlStateNormal];
		return(YES);
		}];

	// UIImageView.image
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIImageView class] property:@"image"] block:^BOOL (id object, NSString *property, id specification, NSError **outError_) {

		UIImageView *theImageView = AssertCast_(UIImageView, object);

		if (IS_DICT(specification))
			{
			if (specification[@"url"])
				{
				NSURL *theURL = [weak_self.typeConverter objectOfClass:[NSURL class] withObject:specification[@"url"] error:outError_];
				if (theURL == NULL)
					{
					return(NO);
					}
				NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL];
				[NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
					NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
					if (theResponse.statusCode == 200)
						{
						UIImage *theImage = [UIImage imageWithData:data];
						theImageView.image = theImage;
						}
					}];

				return(YES);
				}
			}

		UIImage *theImage = [weak_self.typeConverter objectOfClass:[UIImage class] withObject:specification error:outError_];
		if (theImage == NULL)
			{
			return(NO);
			}
		theImageView.image = theImage;
		return(YES);
		}];

    return(YES);
    }

@end
