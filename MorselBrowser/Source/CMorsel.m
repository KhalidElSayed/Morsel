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

#import "CYAMLDeserializer.h"
#import "NSLayoutConstraint+Conveniences.h"

@interface CMorsel ()
@property (readwrite, nonatomic, strong) NSData *data;
@property (readwrite, nonatomic, strong) id rootObject;
@property (readwrite, nonatomic, strong) NSDictionary *globalSpecification;
@property (readwrite, nonatomic, strong) NSDictionary *specification;
@property (readwrite, nonatomic, strong) NSMutableDictionary *objectsByID;
@property (readwrite, nonatomic, strong) NSMutableDictionary *typeTransformers;
@property (readwrite, nonatomic, strong) NSMutableArray *propertyHandlers;
@property (readwrite, nonatomic, strong) NSArray *propertyTypes;
@property (readonly, nonatomic, strong) NSArray *defaults;
@property (readonly, nonatomic, strong) NSDictionary *classSynonyms;
@property (readonly, nonatomic, strong) NSDictionary *keySynonyms;
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
		_propertyHandlers = [NSMutableArray array];
		_typeTransformers = [NSMutableDictionary dictionary];
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
	__weak __typeof(self) weak_self = self;

// x.struct.CGRect
// x.class.NSDictionary / conforms to class, conforms to 'dict', confirms to 'map' etc
// x.container.map
// x.container.hashtable

//	[self addConvertFromType:@"dict" toType:@"CGRect" block:...]
//	[self setType:@"CGRect" forProperty:@"frame" ofClass:[UIView class]];

//	[self addHandlerToClass:[UIView view] property:@"children" block:…];
//	[self addHandlerToClass:[UIView view] property:@"constraints" block:…];

	[self addTypeTransformersForType:@"UIColor" block:^id(id value) {
		return([weak_self colorWithObject:value error:NULL]);
		}];
	[self addTypeTransformersForType:@"UIImage" block:^id(id value) {
		return([weak_self imageWithObject:value error:NULL]);
		}];
	[self addTypeTransformersForType:@"UIFont" block:^id(id value) {
		return([weak_self fontWithSpecification:value error:NULL]);
		}];
	[self addTypeTransformersForType:@"UIImage+UIControlState" block:^id(id value) {
		return(@{ @"image":[weak_self imageWithObject:value error:NULL], @"state":@(UIControlStateNormal)});
		}];
	[self addTypeTransformersForType:@"UIColor+UIControlState" block:^id(id value) {
		return(@{ @"color":[weak_self colorWithObject:value error:NULL], @"state":@(UIControlStateNormal)});
		}];
	[self addTypeTransformersForType:@"NSString+UIControlState" block:^id(id value) {
		return(@{ @"string":value, @"state":@(UIControlStateNormal)});
		}];

	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"title"] block:^(id object, NSString *property, id specification) {
		[(UIButton *)object setTitle:specification forState:UIControlStateNormal];
		}];
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"backgroundImage"] block:^(id object, NSString *property, id specification) {
		[(UIButton *)object setBackgroundImage:specification[@"image"] forState:[specification[@"state"] integerValue]];
		}];
	[self addPropertyHandlerForPredicate:[self predicateForClass:[UIButton class] property:@"titleColor"] block:^(id object, NSString *property, id specification) {
		[(UIButton *)object setTitleColor:specification[@"color"] forState:[specification[@"state"] integerValue]];
		}];

	NSURL *theURL = [[NSBundle mainBundle] URLForResource:@"global" withExtension:@"morsel"];
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	self.globalSpecification = [theDeserializer deserializeURL:theURL error:NULL];

	return(YES);
	}

- (BOOL)process:(NSError **)outError
	{
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	self.specification = [theDeserializer deserializeData:self.data error:NULL];
//	self.specification = [NSDictionary dictionaryWithContentsOfURL:self.URL];
	self.rootObject = [self objectWithSpecificationDictionary:self.specification[@"root"] error:outError];

	return(YES);
	}

#pragma mark -

- (void)addPropertyHandlerForPredicate:(NSPredicate *)inPredicate block:(void (^)(id object, NSString *property, id specification))inBlock
	{
	[self.propertyHandlers addObject:@{
		@"predicate": inPredicate,
		@"block": [inBlock copy],
		}];
	}

- (void)addTypeTransformersForType:(NSString *)inType block:(id (^)(id value))inBlock
	{
	self.typeTransformers[inType] = [inBlock copy];
	}

#pragma mark -

- (id)objectWithSpecificationDictionary:(NSDictionary *)inSpecification error:(NSError **)outError
	{
	NSString *theID = inSpecification[@"id"];
	NSString *theClassName = inSpecification[@"class"];
	Class theClass = [self classWithString:theClassName error:outError];
	if (theClass == NULL)
		{
		return(NULL);
		}

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

	id theObject = NULL;
	if ([theClass isSubclassOfClass:[UIButton class]])
		{
		theObject = [theClass buttonWithType:UIButtonTypeRoundedRect];
		}
	else
		{
		theObject = [[theClass alloc] init];
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

	[theSpecification enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([@[@"id", @"class", @"children", @"constraints"] containsObject:key])
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

		id theValue = obj;
		
		NSString *theType = [self typeForObject:theObject propertyName:theKeyValuePath];
		if (theType != NULL)
			{
			id (^theTypeTransformer)(id value) = self.typeTransformers[theType];
			if (theTypeTransformer)
				{
				theValue = theTypeTransformer(theValue);
				}
			}

		[self setObject:theObject value:theValue forKeyPath:theKeyValuePath];
		}];

	for (__strong id theChildSpecification in theSpecification[@"children"])
		{
		if ([theChildSpecification isKindOfClass:[NSString class]])
			{
			theChildSpecification = self.specification[theChildSpecification];
			}
		id theChild = [self objectWithSpecificationDictionary:theChildSpecification error:outError];

		if (theChild == NULL || [theObject isKindOfClass:[UIView class]] == NO || [theChild isKindOfClass:[UIView class]] == NO)
			{
			return(NULL);
			}

		[theObject addSubview:theChild];
		}

	[theObject setTranslatesAutoresizingMaskIntoConstraints:NO];
	for (id theConstraintsSpecification in theSpecification[@"constraints"])
		{
		NSArray *theConstraints = [self constraintsFromObject:theConstraintsSpecification error:NULL];
		if (theConstraints != NULL)
			{
			[theObject addConstraints:theConstraints];
			}
		}

	return(theObject);
	}

- (void)setObject:(id)inObject value:(id)inValue forKeyPath:(NSString *)inKeyPath
	{
	for (NSDictionary *theDictionary in self.propertyHandlers)
		{
		NSPredicate *thePredicate = theDictionary[@"predicate"];
		if ([thePredicate evaluateWithObject:@{
			@"class": [inObject class],
			@"property": inKeyPath}] == YES)
			{
//			NSLog(@"HIT");
			void (^theBlock)(id object, NSString *property, id specification) = theDictionary[@"block"];
			theBlock(inObject, inKeyPath, inValue);
			return;
			}
		}

	[inObject setValue:inValue forKeyPath:inKeyPath];
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


#pragma mark -

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

- (UIImage *)imageWithObject:(id)inObject error:(NSError **)outError
	{
	UIImage *theImage = NULL;
	if ([inObject isKindOfClass:[NSString class]])
		{
		theImage = [UIImage imageNamed:inObject];
		}
	else if ([inObject isKindOfClass:[NSDictionary class]])
		{
		theImage = [UIImage imageNamed:inObject[@"name"]];
		NSDictionary *theCapInsetsDictionary = inObject[@"capInsets"];
		if (theCapInsetsDictionary)
			{
			UIEdgeInsets theCapInsets;
			theCapInsets.left = [theCapInsetsDictionary[@"left"] floatValue];
			theCapInsets.right = [theCapInsetsDictionary[@"right"] floatValue];
			theCapInsets.top = [theCapInsetsDictionary[@"top"] floatValue];
			theCapInsets.bottom = [theCapInsetsDictionary[@"bottom"] floatValue];
			theImage = [theImage resizableImageWithCapInsets:theCapInsets];
			}
		}
	return(theImage);
	}

@end
