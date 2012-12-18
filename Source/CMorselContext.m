//
//  CMorselContext.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorselContext.h"

#import "CTypeConverter.h"
#import "CYAMLDeserializer.h"
#import "UIColor+Conveniences.h"
#import "Support.h"

@interface CMorselContext ()
@property (readwrite, nonatomic, strong) NSDictionary *globalSpecification;
@property (readwrite, nonatomic, strong) CTypeConverter *typeConverter;
@property (readwrite, nonatomic, strong) NSMutableArray *propertyHandlers;
@end

#pragma mark -

@implementation CMorselContext

@synthesize defaults = _defaults;
@synthesize classSynonyms = _classSynonyms;
@synthesize propertyTypes = _propertyTypes;

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

		NSError *theError = NULL;
		if ([self setup:&theError] == NO)
			{
			NSLog(@"ERROR: Could not create CMorselContext due to: %@", theError);
			self = NULL;
			}
        }
    return self;
    }

- (BOOL)setup:(NSError **)outError
	{
	__weak typeof(self) weakSelf = self;

	// #########################################################################

	NSURL *theURL = [[NSBundle mainBundle] URLForResource:@"global" withExtension:@"morsel"];
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	self.globalSpecification = [theDeserializer deserializeURL:theURL error:outError];
	if (self.globalSpecification == NULL)
		{
		return(NO);
		}

	// #########################################################################

	// NSString -> NSURL
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[NSURL class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([NSURL URLWithString:inValue]);
		}];

	// NSString -> UIColor
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[UIColor class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([UIColor colorwithString:inValue]);
		}];

	// NSDictionary -> UIFont
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[UIFont class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		UIFont *theFont = [UIFont fontWithName:inValue[@"name"] size:[inValue[@"size"] floatValue]];
		return(theFont);
		}];

	// NSString -> UIImage
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationClass:[UIImage class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([weakSelf imageNamed:inValue]);
		}];

	// NSDictionary -> UIImage
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

	// NSDictionary -> CGSize
	[self.typeConverter addConverterForSourceClass:[NSDictionary class] destinationType:@"struct:CGSize" block:^id(id inValue, NSError *__autoreleasing *outError) {
		CGSize theSize = {
			.width = [inValue[@"width"] doubleValue],
			.height = [inValue[@"height"] doubleValue],
			};
		return([NSValue valueWithCGSize:theSize]);
		}];

	// NSArray -> CGSize
	[self.typeConverter addConverterForSourceClass:[NSArray class] destinationType:@"struct:CGSize" block:^id(id inValue, NSError *__autoreleasing *outError) {
		CGSize theSize = {
			.width = [inValue[0] doubleValue],
			.height = [inValue[1] doubleValue],
			};
		return([NSValue valueWithCGSize:theSize]);
		}];

	// UIColor -> CGColor
	[self.typeConverter addConverterForSourceClass:[UIColor class] destinationType:@"special:CGColor" block:^id(id inValue, NSError *__autoreleasing *outError) {
		UIColor *theColor = AssertCast_(UIColor, inValue);
		return((__bridge id)theColor.CGColor);
		}];

	// NSString -> CGColor
	[self.typeConverter addConverterForSourceClass:[NSString class] destinationType:@"special:CGColor" block:^id(id inValue, NSError *__autoreleasing *outError) {
		UIColor *theColor = [self.typeConverter objectOfClass:[UIColor class] withObject:inValue error:outError];
		return((__bridge id)theColor.CGColor);
		}];

	// #########################################################################





	// #########################################################################

	// UIView.size
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"size"] block: ^BOOL (id object, NSString *property, id specification, NSError **outError) {
		UIView *theView = AssertCast_(UIView, object);

		CGSize theSize = [[self.typeConverter objectOfType:@"struct:CGSize" withObject:specification error:NULL] CGSizeValue];

		if (theView.translatesAutoresizingMaskIntoConstraints == YES)
			{
			CGRect theFrame = theView.frame;
			theFrame.size = theSize;
			theView.frame = theFrame;
			}
		else
			{
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:theSize.width]];
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:theSize.height]];
			}

		return(YES);
		}];

	// UIView.width
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"width"] block:^BOOL (id object, NSString *property, id specification, NSError **outError) {
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
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:theScalar]];
			}
		return(YES);
		}];

	// UIView.height
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"height"] block:^BOOL (id object, NSString *property, id specification, NSError **outError) {
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
			[theView addConstraint:[NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:theScalar]];
			}
		return(YES);
		}];

	// UIView.edge-constraints
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIView class] property:@"edge-constraints"] block:^BOOL (id object, NSString *property, id specification, NSError **outError) {
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
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"title"] block:^BOOL (id object, NSString *property, id specification, NSError **outError) {
		[(UIButton *)object setTitle:specification forState:UIControlStateNormal];
		return(YES);
		}];

	// UIButton.backgroundImage
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"backgroundImage"] block:^BOOL (id object, NSString *property, id specification, NSError **outError) {
		UIImage *theImage = [self.typeConverter objectOfClass:[UIImage class] withObject:specification error:outError];
		UIButton *theButton = AssertCast_(UIButton, object);
		[theButton setBackgroundImage:theImage forState:UIControlStateNormal];
		return(YES);
		}];

	// UIImageView.image
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIImageView class] property:@"image"] block:^BOOL (id object, NSString *property, id specification, NSError **outError) {

		UIImageView *theImageView = AssertCast_(UIImageView, object);

		if (IS_DICT(specification))
			{
			if (specification[@"url"])
				{
				NSURL *theURL = [self.typeConverter objectOfClass:[NSURL class] withObject:specification[@"url"] error:NULL];
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

		UIImage *theImage = [self.typeConverter objectOfClass:[UIImage class] withObject:specification error:NULL];
		theImageView.image = theImage;
		return(YES);
		}];

	if ([self loadEnumerations:outError] == NO)
		{
		return(NO);
		}

	return(YES);
	}

- (BOOL)loadEnumerations:(NSError **)outError
	{
	NSURL *theURL = [[NSBundle mainBundle] URLForResource:@"global" withExtension:@"morsel"];
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	NSDictionary *theSpecification = [theDeserializer deserializeURL:theURL error:NULL];

	NSDictionary *theEnumerations = theSpecification[@"enums"];
	[theEnumerations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

		NSString *theEnumerationName = key;
		NSDictionary *theEnumerationKeyValues = obj;
		NSString *theEnumerationType = [NSString stringWithFormat:@"enum:%@", theEnumerationName];

		[self.typeConverter addConverterForSourceClass:[NSString class] destinationType:theEnumerationType block:^id(id inValue, NSError *__autoreleasing *outError) {
			id theValue = theEnumerationKeyValues[inValue];
			if (theValue == NULL)
				{
				AssertUnimplemented_();
				}
			return(theValue);
			}];

		[self.typeConverter addConverterForSourceClass:[NSNumber class] destinationType:theEnumerationType block:^id(id inValue, NSError *__autoreleasing *outError) {
			return(inValue);
			}];
		}];

	return(YES);
	}

- (NSArray *)defaults
	{
	if (_defaults == NULL)
		{
		NSMutableArray *theDefaults = [NSMutableArray array];
		if (self.globalSpecification[@"defaults"])
			{
			[theDefaults addObjectsFromArray:self.globalSpecification[@"defaults"]];
			}
		_defaults = [theDefaults copy];
		}
	return(_defaults);
	}

- (NSDictionary *)classSynonyms
	{
	if (_classSynonyms == NULL)
		{
		NSMutableDictionary *theClassSynonyms = [NSMutableDictionary dictionary];
		if (self.globalSpecification[@"class-synonyms"])
			{
			[theClassSynonyms addEntriesFromDictionary:self.globalSpecification[@"class-synonyms"]];
			}
		}
	return(_classSynonyms);
	}

- (NSArray *)propertyTypes
	{
	if (_propertyTypes == NULL)
		{
		NSMutableArray *thePropertyTypes = [NSMutableArray array];

		for (NSDictionary *thePropertyType in self.globalSpecification[@"property-types"])
			{
			Class theClass = NSClassFromString(thePropertyType[@"class"]);

			NSPredicate *thePredicate = [self predicateForClass:theClass property:thePropertyType[@"property"]];
			[thePropertyTypes addObject:@{
				@"predicate": thePredicate,
				@"type": thePropertyType,
				}];
			}
		_propertyTypes = [thePropertyTypes copy];
		}
	return(_propertyTypes);
	}


#pragma mark -

- (void)addPropertyHandlerForPredicate:(NSPredicate *)inPredicate block:(BOOL (^)(id object, NSString *property, id specification, NSError **outError))inBlock
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

@end
