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

#import "CTypeConverter.h"
#import "CYAMLDeserializer.h"
#import "NSLayoutConstraint+Conveniences.h"
#import "CMorselContext.h"

@interface CMorsel ()
@property (readwrite, nonatomic, strong) NSData *data;
@property (readwrite, nonatomic, strong) id rootObject;
@property (readwrite, nonatomic, strong) NSDictionary *globalSpecification;
@property (readwrite, nonatomic, strong) NSDictionary *specification;
@property (readwrite, nonatomic, strong) NSMutableDictionary *objectsByID;
@property (readwrite, nonatomic, strong) NSArray *propertyTypes;
@property (readonly, nonatomic, strong) NSArray *defaults;
@property (readonly, nonatomic, strong) NSDictionary *classSynonyms;
@property (readonly, nonatomic, strong) NSDictionary *keySynonyms;
@property (readwrite, nonatomic, strong) CMorselContext *context;
@end

#pragma mark -

@implementation CMorsel

@synthesize defaults = _defaults;
@synthesize classSynonyms = _classSynonyms;
@synthesize keySynonyms = _keySynonyms;
@synthesize propertyTypes = _propertyTypes;

- (id)initWithData:(NSData *)inData error:(NSError **)outError;
	{
    if ((self = [super init]) != NULL)
        {
		_data = inData;
		_objectsByID = [NSMutableDictionary dictionary];
		_context = [CMorselContext defaultContext];
		[self setup:NULL];
		[self process:NULL];
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

#pragma mark -

- (NSArray *)defaults
	{
	if (_defaults == NULL)
		{
		NSMutableArray *theDefaults = [NSMutableArray array];
		if (self.globalSpecification[@"defaults"])
			{
			[theDefaults addObjectsFromArray:self.globalSpecification[@"defaults"]];
			}
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
		if (self.globalSpecification[@"class-synonyms"])
			{
			[theClassSynonyms addEntriesFromDictionary:self.globalSpecification[@"class-synonyms"]];
			}
		if (self.specification[@"class-synonyms"])
			{
			[theClassSynonyms addEntriesFromDictionary:self.specification[@"class-synonyms"]];
			}
		_classSynonyms = [theClassSynonyms copy];
		}
	return(_classSynonyms);
	}

- (NSDictionary *)keySynonyms
	{
	if (_keySynonyms == NULL)
		{
		NSMutableDictionary *theKeySynonyms = [NSMutableDictionary dictionary];
		if (self.globalSpecification[@"key-synonyms"])
			{
			[theKeySynonyms addEntriesFromDictionary:self.globalSpecification[@"key-synonyms"]];
			}
		if (self.specification[@"key-synonyms"])
			{
			[theKeySynonyms addEntriesFromDictionary:self.specification[@"key-synonyms"]];
			}
		_keySynonyms = [theKeySynonyms copy];
		}
	return(_keySynonyms);
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
				@"type": thePropertyType[@"type"],
				}];
			}

		_propertyTypes = [thePropertyTypes copy];
		}
	return(_propertyTypes);
	}

#pragma mark -

 
- (BOOL)setup:(NSError **)outError
	{
	NSURL *theURL = [[NSBundle mainBundle] URLForResource:@"global" withExtension:@"morsel"];
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	self.globalSpecification = [theDeserializer deserializeURL:theURL error:NULL];

	return(YES);
	}

- (BOOL)process:(NSError **)outError
	{
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	NSError *theError = NULL;
	self.specification = [theDeserializer deserializeData:self.data error:&theError];
	if (self.specification == NULL)
		{
		NSLog(@"%@", theError);
		return(NO);
		}
	else
		{
		self.rootObject = [self objectWithSpecificationDictionary:self.specification[@"root"] root:YES error:outError];
		if (self.rootObject != NULL)
			{
			[self populateObject:self.rootObject withSpecificationDictionary:self.specification[@"root"] error:outError];
			}
		return(YES);
		}
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
		theObject = [theClass buttonWithType:UIButtonTypeRoundedRect];
		}
	else
		{
		theObject = [[theClass alloc] init];
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

	[theSpecification enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([@[@"id", @"class", @"subviews", @"constraints"] containsObject:key])
			{
			return;
			}

		NSString *theKeyValuePath = [self expandKey:key error:NULL];
		if (theKeyValuePath == NULL)
			{
			return;
			}

		if ([obj isKindOfClass:[NSString class]])
			{
			NSString *theParameterName = obj;
			if ([theParameterName characterAtIndex:0] == '$')
				{
				theParameterName = [theParameterName substringFromIndex:1];
				obj = self.specification[@"parameters"][theParameterName];
				}
			}

		// #####################################################################

		id theValue = obj;
		
		[self setObject:inObject value:theValue forKeyPath:theKeyValuePath];
		}];

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

		[self populateObject:theChild withSpecificationDictionary:theChildSpecification error:NULL];
		}

	// #########################################################################

	for (id theConstraintsSpecification in theSpecification[@"constraints"])
		{
		NSArray *theConstraints = [self constraintsFromObject:theConstraintsSpecification error:NULL];
		if (theConstraints != NULL)
			{
			[inObject addConstraints:theConstraints];
			}
		}

	return(YES);
	}

- (BOOL)setObject:(id)inObject value:(id)inValue forKeyPath:(NSString *)inKeyPath
	{
	id theValue = inValue;

	NSString *theType = [self typeForObject:inObject propertyName:inKeyPath];
	if (theType != NULL)
		{
		id theNewValue = [self.context.typeConverter objectOfType:theType withObject:theValue error:NULL];
		if (theNewValue != NULL)
			{
			theValue = theNewValue;
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
			void (^theBlock)(id object, NSString *property, id specification) = theDictionary[@"block"];
			theBlock(inObject, inKeyPath, theValue);
			return(YES);
			}
		}

	if (theValue == NULL)
		{
		NSLog(@"TODO: We want an error param here!");
		return(NO);
		}

	[inObject setValue:theValue forKeyPath:inKeyPath];
	return(YES);
	}

- (Class)classWithString:(NSString *)inString error:(NSError **)outError
	{
	inString = self.classSynonyms[inString] ?: inString;
	Class theClass = NSClassFromString(inString);
	return(theClass);
	}

- (NSString *)expandKey:(NSString *)inKey error:(NSError **)outError
	{
	inKey = self.keySynonyms[inKey] ?: inKey;
	return(inKey);
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

- (NSString *)typeForObject:(id)inObject propertyName:(NSString *)inPropertyName
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
	else if (theSpecification[@"align-top"])
		{
		NSArray *theViews = [self objectsWithIDs:theSpecification[@"align-top"]];
		theConstraints = [NSLayoutConstraint constraintsForViews:theViews alignedOnAttribute:NSLayoutAttributeTop];
		}
	else
		{
		NSLog(@"Do not understand constraint: %@", inObject);
		}
	return(theConstraints);
	}

@end
