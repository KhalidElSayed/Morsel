//
//  CMorsel.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorsel.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "MorselSupport.h"
#import "MorselAsserts.h"

#import "CTypeConverter.h"
#import "CYAMLDeserializer.h"
#import "NSLayoutConstraint+Conveniences.h"
#import "CMorselContext.h"
#import "NSObject+Hacks.h"
#import "UIView+MorselExtensions.h"
#import "NSLayoutConstraint+MorselExtensions.h"

@interface CMorsel ()
// Morsel properties...
@property (readwrite, nonatomic, strong) NSData *data;
@property (readwrite, nonatomic, strong) NSDictionary *specification;
@property (readwrite, nonatomic, strong) NSArray *propertyTypes;
@property (readonly, nonatomic, strong) NSArray *defaults;
@property (readonly, nonatomic, strong) NSDictionary *classSynonyms;

// Session properties...
@property (readwrite, nonatomic, strong) id owner;
@property (readwrite, nonatomic, strong) NSMutableDictionary *objectsByID;
@end

#pragma mark -

@implementation CMorsel

@synthesize context = _context;
@synthesize defaults = _defaults;
@synthesize classSynonyms = _classSynonyms;
@synthesize propertyTypes = _propertyTypes;

- (id)initWithData:(NSData *)inData error:(NSError **)outError;
	{
    if ((self = [super init]) != NULL)
        {
		_data = inData;
        }
    return self;
	}

- (id)initWithURL:(NSURL *)inURL error:(NSError **)outError
    {
	NSData *theData = [NSData dataWithContentsOfURL:inURL options:0 error:outError];
	if (theData == NULL)
		{
		self = NULL;
		return(NULL);
		}

    if ((self = [self initWithData:theData error:outError]) != NULL)
        {
        }
    return self;
    }

- (id)initWithName:(NSString *)inName bundle:(NSBundle *)inBundle error:(NSError **)outError;
	{
	inBundle = inBundle ?: [NSBundle mainBundle];
	NSURL *theURL = [inBundle URLForResource:inName withExtension:@"morsel"];
	return([self initWithURL:theURL error:outError]);
	}

#pragma mark -

- (CMorselContext *)context
	{
	if (_context == NULL)
		{
		_context = [CMorselContext defaultContext];
		}
	return(_context);
	}

- (NSArray *)defaults
	{
	if (_defaults == NULL)
		{
		NSMutableArray *theDefaults = [NSMutableArray array];
		[theDefaults addObjectsFromArray:self.context.defaults];
		if (self.specification[@"defaults"])
			{
			[theDefaults addObjectsFromArray:self.specification[@"defaults"]];
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
		[theClassSynonyms addEntriesFromDictionary:self.context.classSynonyms];
		if (self.specification[@"class-synonyms"])
			{
			[theClassSynonyms addEntriesFromDictionary:self.specification[@"class-synonyms"]];
			}
		_classSynonyms = [theClassSynonyms copy];
		}
	return(_classSynonyms);
	}

- (NSArray *)propertyTypes
	{
	if (_propertyTypes == NULL)
		{
		NSMutableArray *thePropertyTypes = [self.context.propertyTypes mutableCopy];

		for (NSDictionary *thePropertyType in self.specification[@"property-types"])
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

- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil error:(NSError **)outError
	{
	self.objectsByID = [NSMutableDictionary dictionary];
	self.owner = ownerOrNil;

	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];

	self.specification = [theDeserializer deserializeData:self.data error:outError];
	if (self.specification == NULL)
		{
		return(NO);
		}

	id theRootObject = [self objectWithSpecificationDictionary:self.specification[@"root"] root:YES error:outError];
	if (theRootObject == NULL)
		{
		return(NULL);
		}

	if ([self populateObject:theRootObject withSpecificationDictionary:self.specification[@"root"] error:outError] == NO)
		{
		return(NULL);
		}

	NSDictionary *theOwnerDictionary = self.specification[@"owner"];
	if (self.owner && theOwnerDictionary != NULL)
		{
		if (theOwnerDictionary[@"view"])
			{
			NSString *theViewID = theOwnerDictionary[@"view"];
			id theView = self.objectsByID[theViewID];
			AssertCast_(UIViewController, self.owner).view = theView;
			}

		NSDictionary *theOutlets = theOwnerDictionary[@"outlets"];
		[theOutlets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

			id theOutletObject = self.objectsByID[obj];
			[self.owner setValue:theOutletObject forKey:key];


			}];
		}

	// At the moment we just care about the root object...
	NSArray *theObjects = @[ theRootObject ];

	return(theObjects);
	}

#pragma mark -

- (id)objectWithSpecificationDictionary:(NSDictionary *)inSpecification root:(BOOL)inRoot error:(NSError **)outError
	{
	NSString *theID = inSpecification[@"id"] ?: @"root";
	NSString *theClassName = inSpecification[@"class"];
	Class theClass = [self classWithString:theClassName error:outError];
	if (theClass == NULL)
		{
		NSLog(@"Failed to load class of type %@", theClassName);
		return(NULL);
		}

	id theObject = NULL;
	if ([theClass isSubclassOfClass:[UIButton class]])
		{
		// TODO - this is a total hack
		UIButtonType theButtonType = UIButtonTypeRoundedRect;
		if (inSpecification[@"backgroundImage"] != NULL)
			{
			theButtonType = UIButtonTypeCustom;
			}
		theObject = [theClass buttonWithType:theButtonType];
		}
	else
		{
		theObject = [[theClass alloc] init];
		}

	if ([theObject respondsToSelector:@selector(setMorselID:)])
		{
		[theObject setMorselID:theID];
		}


	if ([theClass isSubclassOfClass:[UIView class]])
		{
		[theObject setTranslatesAutoresizingMaskIntoConstraints:NO];
		}

	if (theObject == NULL)
		{
		NSLog(@"Failed to create object");
		return(NULL);
		}

	if (theID != NULL)
		{
		self.objectsByID[theID] = theObject;
		}


	return(theObject);
	}

- (BOOL)populateObject:(id)inObject withSpecificationDictionary:(NSDictionary *)inSpecification error:(NSError **)outError
	{
	NSString *theID = inSpecification[@"id"];
	Class theClass = [inObject class];

	NSMutableDictionary *theDefaultSpecification = [NSMutableDictionary dictionary];

	for (NSDictionary *theDefault in self.defaults)
		{
		if ([theDefault[@"ids"] containsObject:theID])
			{
			[theDefaultSpecification addEntriesFromDictionary:theDefault];
			[theDefaultSpecification removeObjectForKey:@"ids"];
			}
		else if ([theClass isSubclassOfClass:[self classWithString:theDefault[@"class"] error:NULL]])
			{
			[theDefaultSpecification addEntriesFromDictionary:theDefault];
			[theDefaultSpecification removeObjectForKey:@"ids"];
			}
		}

	[theDefaultSpecification addEntriesFromDictionary:inSpecification];
	NSDictionary *theSpecification = theDefaultSpecification;

	// #########################################################################

	__block NSError *theError = NULL;
	[theSpecification enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([@[@"id", @"class", @"subviews", @"constraints", @"action", @"target"] containsObject:key])
			{
			return;
			}

		id theValue = obj;
		
		if ([self setObject:inObject value:theValue forKeyPath:key error:&theError] == NO)
			{
			*stop = YES;
			}
		}];
	if (theError != NULL)
		{
		if (outError)
			{
			*outError = theError;
			}
		return(NO);
		}

	// #########################################################################

	for (__strong id theChildSpecification in theSpecification[@"subviews"])
		{
		if ([theChildSpecification isKindOfClass:[NSString class]])
			{
			theChildSpecification = self.specification[theChildSpecification];
			}
		id theChild = [self objectWithSpecificationDictionary:theChildSpecification root:NO error:outError];

		if (theChild == NULL || [inObject isKindOfClass:[UIView class]] == NO || [theChild isKindOfClass:[UIView class]] == NO)
			{
			NSLog(@"WARNING: HUH?");
			return(NO);
			}

		[inObject addSubview:theChild];

		if ([self populateObject:theChild withSpecificationDictionary:theChildSpecification error:outError] == NO)
			{
			return(NO);
			}
		}

	// #########################################################################

	for (id theConstraintsSpecification in theSpecification[@"constraints"])
		{
		NSArray *theConstraints = [self constraintsFromObject:theConstraintsSpecification error:outError];
		if (theConstraints == NULL)
			{
			return(NO);
			}

		[inObject addConstraints:theConstraints];
		}

	// #########################################################################

	NSString *theActionName = theSpecification[@"action"];
	if (theActionName != NULL)
		{
		id theTarget = self.owner;
		if (theTarget == NULL)
			{
			NSLog(@"WARNING: Could not find a default target");
			}
		else
			{
			UIControlEvents theControlEvents = UIControlEventTouchUpInside;

			if ([theActionName isKindOfClass:[NSString class]])
				{
				SEL theAction = NSSelectorFromString(theActionName);
				if ([theTarget respondsToSelector:theAction] == NO)
					{
					if ([theActionName characterAtIndex:theActionName.length - 1] == ':')
						{
						theActionName = [theActionName substringToIndex:theActionName.length - 1];
						}
					else
						{
						theActionName = [theActionName stringByAppendingString:@":"];
						}
					theAction = NSSelectorFromString(theActionName);
					if ([theTarget respondsToSelector:theAction] == NO)
						{
						NSLog(@"WARNING: %@ does not support selector: %@", theTarget, theActionName);
						}
					}

				if (theTarget != NULL && theAction != NULL)
					{
					[(UIControl *)inObject addTarget:theTarget action:theAction forControlEvents:theControlEvents];
					}
				}
			}
		}
	return(YES);
	}

- (BOOL)setObject:(id)inObject value:(id)inValue forKeyPath:(NSString *)inKeyPath error:(NSError **)outError
	{
	id theValue = inValue;

	NSDictionary *theTypeDictionary = [self typeForObject:inObject propertyName:inKeyPath];
	inKeyPath = theTypeDictionary[@"keyPath"] ?: inKeyPath;

	if ([inValue isKindOfClass:[NSString class]])
		{
		NSString *theParameterName = inValue;
		if (theParameterName.length > 1 && [theParameterName characterAtIndex:0] == '$')
			{
			theParameterName = [theParameterName substringFromIndex:1];
			inValue = self.specification[@"parameters"][theParameterName];
			}
		}

	NSDictionary *theTestDictionary = @{
		@"class": [inObject class],
		@"property": inKeyPath
		};

	for (NSDictionary *theDictionary in self.context.propertyHandlers)
		{
		NSPredicate *thePredicate = theDictionary[@"predicate"];
		if ([thePredicate evaluateWithObject:theTestDictionary] == YES)
			{
			MorselPropertyHandler theBlock = theDictionary[@"block"];
			theBlock(inObject, inKeyPath, theValue, outError);
			return(YES);
			}
		}

	if (theValue == NULL)
		{
		NSLog(@"TODO: We want an error param here!");
		return(NO);
		}

	NSArray *theComponents = [inKeyPath componentsSeparatedByString:@"."];
	if (theComponents.count > 1)
		{
		for (NSString *theComponent in [theComponents subarrayWithRange:(NSRange){ .length = theComponents.count - 1 }])
			{
			inObject = [inObject valueForKey:theComponent];
			if (inObject == NULL)
				{
				NSParameterAssert(NO);
				}
			}
		}
	NSString *theKey = [theComponents lastObject];

	theTypeDictionary = [self typeForObject:inObject propertyName:theKey];
	NSString *theType = theTypeDictionary[@"type"];
	if (theType != NULL)
		{
		id theNewValue = [self.context.typeConverter objectOfType:theType withObject:theValue error:NULL];
		if (theNewValue != NULL)
			{
			theValue = theNewValue;
			}
		}

	@try
		{
		[inObject setValue:theValue forKeyPath:theKey];
		}
	@catch (NSException *exception)
		{
		NSLog(@"Cannot set %@ to %@ on %@", theKey, theValue, inObject);
		NSLog(@"%@", exception);
		return(NO);
		}
	return(YES);
	}

- (Class)classWithString:(NSString *)inString error:(NSError **)outError
	{
	inString = self.classSynonyms[inString] ?: inString;
	Class theClass = NSClassFromString(inString);
	return(theClass);
	}

- (NSArray *)objectsWithIDs:(NSArray *)inIDs
	{
	NSMutableArray *theObjects = [NSMutableArray array];
	for (NSString *theIdentifier in inIDs)
		{
		[theObjects addObject:self.objectsByID[theIdentifier]];
		}
	return(theObjects);
	}

- (id)expandSpecification:(id)inSpecification
	{
	return(inSpecification);
	}

- (NSDictionary *)typeForObject:(id)inObject propertyName:(NSString *)inPropertyName
	{
	for (NSDictionary *thePropertyType in self.propertyTypes)
		{
		NSPredicate *thePredicate = thePropertyType[@"predicate"];
		if ([thePredicate evaluateWithObject:@{
			@"class": [inObject class],
			@"property": inPropertyName}] == YES)
			{
			return(thePropertyType[@"type"]);
			}
		}
	return(NULL);
	}

#pragma mark -

- (NSPredicate *)predicateForClass:(Class)inClass property:(NSString *)inProperty
	{
	NSPredicate *thePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		return([((Class)evaluatedObject[@"class"]) isSubclassOfClass:inClass] && [evaluatedObject[@"property"] isEqualToString:inProperty]);
		}];
	return(thePredicate);
	}

#pragma mark -

- (NSArray *)constraintsFromObject:(id)inObject error:(NSError **)outError
	{
	NSArray *theConstraints = NULL;
	id theSpecification = inObject;
	if ([theSpecification[@"type"] isEqualToString:@"visual"])
		{
		NSString *theFormat = theSpecification[@"format"];
		theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:theFormat options:0 metrics:self.specification[@"metrics"] views:self.objectsByID];
		}
	else if (theSpecification[@"visual"])
		{
		theSpecification = theSpecification[@"visual"];
		if ([theSpecification isKindOfClass:[NSString class]])
			{
			NSString *theFormat = theSpecification;
			theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:theFormat options:0 metrics:self.specification[@"metrics"] views:self.objectsByID];
			}
		else if ([theSpecification isKindOfClass:[NSArray class]])
			{
			NSString *theFormat = theSpecification[0];

			NSString *theOptionsString = theSpecification[1];
			NSDictionary *theOptionsByName = @{
				@"baseline": @(NSLayoutFormatAlignAllBaseline),
				@"leading": @(NSLayoutFormatAlignAllLeading),
				};
			NSLayoutFormatOptions theOptions = [theOptionsByName[theOptionsString] integerValue];


			theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:theFormat options:theOptions metrics:self.specification[@"metrics"] views:self.objectsByID];
			}
		else if ([theSpecification isKindOfClass:[NSDictionary class]])
			{
			NSString *theFormat = theSpecification[@"visual"];

			NSString *theOptionsString = theSpecification[@"options"];
			NSDictionary *theOptionsByName = @{
				@"baseline": @(NSLayoutFormatAlignAllBaseline),
				@"leading": @(NSLayoutFormatAlignAllLeading),
				};
			NSLayoutFormatOptions theOptions = [theOptionsByName[theOptionsString] integerValue];
			theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:theFormat options:theOptions metrics:self.specification[@"metrics"] views:self.objectsByID];
			}
		}
	else if (theSpecification[@"align-left"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"align-left"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews alignedOnAttribute:NSLayoutAttributeLeft];
		}
	else if (theSpecification[@"align-right"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"align-right"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews alignedOnAttribute:NSLayoutAttributeRight];
		}
	else if (theSpecification[@"align-top"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"align-top"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews alignedOnAttribute:NSLayoutAttributeTop];
		}
	else if (theSpecification[@"align-bottom"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"align-bottom"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews alignedOnAttribute:NSLayoutAttributeTop];
		}
	else if (theSpecification[@"align-baseline"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"align-baseline"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews alignedOnAttribute:NSLayoutAttributeBaseline];
		}
	else if (theSpecification[@"distribute-horizontally"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"distribute-horizontally"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews distributed:UILayoutConstraintAxisHorizontal];
		}
	else if (theSpecification[@"distribute-vertically"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"distribute-vertically"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews distributed:UILayoutConstraintAxisVertical];
		}
	else if (theSpecification[@"center-x"])
		{
		id theValue = theSpecification[@"center-x"];
		if (IS_STRING(theValue))
			{
			UIView *theView = self.objectsByID[theValue];

			NSLayoutConstraint *theConstraint = [NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:theView.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
			theConstraints = @[theConstraint];
			}
		}
	else if (theSpecification[@"center-y"])
		{
		id theValue = theSpecification[@"center-y"];
		if (IS_STRING(theValue))
			{
			UIView *theView = self.objectsByID[theValue];

			NSLayoutConstraint *theConstraint = [NSLayoutConstraint constraintWithItem:theView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:theView.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
			theConstraints = @[theConstraint];
			}
		}
	else
		{
		NSLog(@"Do not understand constraint: %@", inObject);
		}
	return(theConstraints);
	}

@end
