//
//  CMorselContext.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorselContext.h"

#import "CTypeConverter.h"

#define IS_STRING(o) [o isKindOfClass:[NSString class]]
#define IS_ARRAY(o) [o isKindOfClass:[NSArray class]]
#define IS_DICT(o) [o isKindOfClass:[NSDictionary class]]

@interface CMorselContext ()
@property (readwrite, nonatomic, strong) CTypeConverter *typeConverter;
@property (readwrite, nonatomic, strong) NSMutableArray *propertyHandlers;
@end

#pragma mark -

@implementation CMorselContext

static CMorselContext *gSharedInstance = NULL;

+ (CMorselContext *)defaultContext
    {
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
        gSharedInstance = [[CMorselContext alloc] init];
        });
    return(gSharedInstance);
    }

#pragma mark -

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
		_typeConverter = [[CTypeConverter alloc] init];
		_propertyHandlers = [NSMutableArray array];

		[self setup];
        }
    return self;
    }

- (void)setup
	{
	__weak typeof(self) weakSelf = self;

	// #########################################################################

	// NSURL
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[NSURL class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([NSURL URLWithString:inValue]);
		}];

	// UIColor
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[UIColor class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([weakSelf colorWithObject:inValue error:NULL]);
		}];

	// UIFont
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[UIFont class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([weakSelf fontWithSpecification:inValue error:NULL]);
		}];

	// UIImage
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[UIImage class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([weakSelf imageNamed:inValue]);
		}];

	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[UIImage class] block:^id(id inValue, NSError *__autoreleasing *outError) {

		UIImage *theImage = [weakSelf imageNamed:inValue[@"name"]];
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


	// #########################################################################

	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"title"] block:^(id object, NSString *property, id specification) {
		[(UIButton *)object setTitle:specification forState:UIControlStateNormal];
		}];
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"backgroundImage"] block:^(id object, NSString *property, id specification) {
		[(UIButton *)object setBackgroundImage:specification[@"image"] forState:[specification[@"state"] integerValue]];
		}];
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"titleColor"] block:^(id object, NSString *property, id specification) {
		[(UIButton *)object setTitleColor:specification[@"color"] forState:[specification[@"state"] integerValue]];
		}];

	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIImageView class] property:@"image"] block:^(id object, NSString *property, id specification) {
		if (IS_DICT(specification))
			{
			if (specification[@"url"])
				{
				NSURL *theURL = [self.typeConverter objectOfClass:[NSURL class] withObject:specification[@"url"] error:NULL];
				NSURLRequest *theREquest = [NSURLRequest requestWithURL:theURL];
				[NSURLConnection sendAsynchronousRequest:theREquest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
					NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
					if (theResponse.statusCode == 200)
						{
						UIImage *theImage = [UIImage imageWithData:data];
						((UIImageView *)object).image = theImage;
						}
					}];
				}
			else
				{
				UIImage *theImage = [self.typeConverter objectOfClass:[UIImage class] withObject:specification error:NULL];
				((UIImageView *)object).image = theImage;
				}
			}
		}];
	}

- (void)addPropertyHandlerForPredicate:(NSPredicate *)inPredicate block:(void (^)(id object, NSString *property, id specification))inBlock
	{
	[self.propertyHandlers addObject:@{
		@"predicate": inPredicate,
		@"block": [inBlock copy],
		}];
	}

- (NSPredicate *)predicateForClass:(Class)inClass property:(NSString *)inProperty
	{
	NSPredicate *thePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		return([((Class)evaluatedObject[@"class"]) isSubclassOfClass:inClass] && [evaluatedObject[@"property"] isEqualToString:inProperty]);
		}];
	return(thePredicate);
	}

#pragma mark -

- (UIImage *)imageNamed:(NSString *)inName
	{
	return([UIImage imageNamed:inName]);
	}

- (UIFont *)fontWithSpecification:(id)inSpecification error:(NSError **)outError
	{
	UIFont *theFont = [UIFont fontWithName:inSpecification[@"name"] size:[inSpecification[@"size"] floatValue]];
	return(theFont);
	}

- (UIColor *)colorWithObject:(id)inObject error:(NSError **)outError
	{
	NSDictionary *theColors = @{
		@"clearColor": [UIColor clearColor],
		@"redColor": [UIColor redColor],
		@"greenColor": [UIColor greenColor],
		@"grayColor": [UIColor grayColor],
		@"blueColor": [UIColor blueColor],
		@"whiteColor": [UIColor whiteColor],
		};
	return(theColors[inObject]);
	}

- (CGRect)rectWithObject:(id)inObject error:(NSError **)outError
	{
	NSArray *theArray = inObject;
	CGRect theRect;
	theRect.origin.x = [theArray[0] floatValue];
	theRect.origin.y = [theArray[1] floatValue];
	theRect.size.width = [theArray[2] floatValue];
	theRect.size.height = [theArray[3] floatValue];
	return(theRect);
	}

@end
