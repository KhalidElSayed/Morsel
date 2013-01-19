//
//	CMorsel.m
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

#import "CMorsel.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "MorselSupport.h"
#import "MorselAsserts.h"

#import "CTypeConverter.h"
#import "NSLayoutConstraint+Conveniences.h"
#import "CMorselContext.h"
#import "UIView+MorselExtensions.h"
#import "NSLayoutConstraint+DebugExtensions.h"

@interface CMorsel ()
// Morsel properties...
@property (readonly, nonatomic, strong) NSURL *URL;
@property (readwrite, nonatomic, strong) NSDictionary *specification;
@property (readwrite, nonatomic, strong) NSArray *propertyTypes;
@property (readonly, nonatomic, strong) NSArray *defaults;
@property (readonly, nonatomic, strong) NSDictionary *classSynonyms;
@property (readonly, nonatomic, strong) CTypeConverter *typeConverter;

// Session properties...
@property (readwrite, nonatomic, strong) id owner;
@property (readwrite, nonatomic, strong) NSMutableDictionary *objectsByID;
@property (readwrite, nonatomic, strong) NSMutableDictionary *outletIDs;
@end

#pragma mark -

@implementation CMorsel

@synthesize context = _context;
@synthesize defaults = _defaults;
@synthesize classSynonyms = _classSynonyms;
@synthesize propertyTypes = _propertyTypes;

- (id)initWithURL:(NSURL *)inURL error:(NSError **)outError
    {
	NSParameterAssert(inURL != NULL);

    if ((self = [self init]) != NULL)
        {
		_URL = inURL;
        _URL = inURL;
        }
    return self;
                }
            if ([weak_self populateObject:theObject withSpecificationDictionary:inValue error:outError] == NO)
                {
                return(NULL);
                }
            return(theObject);
            }];
		}
	return(self);
    }

- (id)initWithName:(NSString *)inName bundle:(NSBundle *)inBundle error:(NSError **)outError;
	{
	inBundle = inBundle ?: [NSBundle mainBundle];
	NSURL *theURL = [inBundle URLForResource:inName withExtension:@"morsel"];
    if ([theURL checkResourceIsReachableAndReturnError:NULL] == NO || YES)
        {
        theURL = [inBundle URLForResource:inName withExtension:@"plist"];
        }
	return([self initWithURL:theURL error:outError]);
	}

#pragma mark -

- (void)setup
    {
    _typeConverter = [[CTypeConverter alloc] init];

    __weak CMorsel *weak_self = self;

    [_typeConverter addConverterForSourceClass:[NSString class] destinationType:@"special:lookup" block:^id(id inValue, NSError *__autoreleasing *outError) {
        return(self.objectsByID[inValue]);
        }];

    [_typeConverter addConverterForSourceClass:[NSDictionary class] destinationClass:[UIView class] block:^id(id inValue, NSError *__autoreleasing *outError) {
        id theObject = [weak_self objectWithSpecificationDictionary:inValue error:outError];
        if (theObject == NULL)
            {
            return(NULL);
            }
        if ([weak_self populateObject:theObject withSpecificationDictionary:inValue error:outError] == NO)
            {
            return(NULL);
            }
        return(theObject);
        }];
    }

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

- (NSDictionary *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil error:(NSError **)outError
	{
    [self prepare];


	self.owner = ownerOrNil;

    if (self.specification == NULL)
        {
        if ([[self.URL pathExtension] isEqualToString:@"morsel"])
            {
            self.specification = [self.context deserializeURL:self.URL error:outError];
            if (self.specification == NULL)
                {
                return(NO);
                }
            }
        if ([[self.URL pathExtension] isEqualToString:@"plist"])
            {
            self.specification = [NSDictionary dictionaryWithContentsOfURL:self.URL];
            if (self.specification == NULL)
                {
                return(NO);
                }
            }
        }

    NSMutableDictionary *theObjects = [NSMutableDictionary dictionary];
    NSArray *theObjectSpecifications = self.specification[@"objects"];
    for (NSDictionary *theSpecification in theObjectSpecifications)
        {
        NSString *theObjectID = theSpecification[@"id"];
        id theObject = [self objectWithSpecificationDictionary:theSpecification error:outError];
        if (theObject == NULL)
            {
            return(NULL);
            }

        if ([self populateObject:theObject withSpecificationDictionary:theSpecification error:outError] == NO)
            {
            return(NULL);
            }

        theObjects[theObjectID] = theObject;
        }

    if ([self configureOwner:outError] == NO)
        {
        return(NO);
        }

	return(theObjects);
	}

- (BOOL)instantiateWithRoot:(id)root owner:(id)owner options:(NSDictionary *)optionsOrNil error:(NSError **)outError;
	{
    [self prepare];
	self.owner = owner;

	self.specification = [self.context deserializeObjectWithURL:self.URL error:outError];
	if (self.specification == NULL)
		{
		return(NO);
		}

	// TODO: This is a little bit of a hack - but is faster than instantiating all objects...
    NSDictionary *theRootObjectSpecification = [self.specification[@"objects"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == 'root'"]][0];
    if (theRootObjectSpecification == NULL)
        {
        if (outError)
            {
            *outError = [self errorWithCode:-1 localizedDescription:@"Could not find an object specification with id 'root'." userInfo:NULL];
            }
        return(NO);
        }

	if ([self populateObject:root withSpecificationDictionary:theRootObjectSpecification error:outError] == NO)
		{
		return(NO);
		}

    if ([self configureOwner:outError] == NO)
        {
        return(NO);
        }

	return(YES);
	}

- (BOOL)configureOwner:(NSError **)outError
    {
	if (self.owner == NULL)
        {
        return(YES);
        }

	NSDictionary *theOwnerDictionary = self.specification[@"owner"];

    if (theOwnerDictionary[@"class"])
        {
        Class theOwnerClass = NSClassFromString(theOwnerDictionary[@"class"]);
        if ([self.owner isKindOfClass:theOwnerClass] == NO)
            {
            NSLog(@"Warning: Owner class does not match class");
            }
        }

    if (theOwnerDictionary[@"view"])
        {
        NSString *theViewID = theOwnerDictionary[@"view"];
        id theView = self.objectsByID[theViewID];
        AssertCast_(UIViewController, self.owner).view = theView;
        }

    NSMutableDictionary *theOutlets = [NSMutableDictionary dictionary];
    if (theOwnerDictionary[@"outlets"] != NULL)
        {
        [theOutlets addEntriesFromDictionary:theOwnerDictionary[@"outlets"]];
        }
    [theOutlets addEntriesFromDictionary:self.outletIDs];

    [theOutlets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id theOutletObject = self.objectsByID[obj];
        @try
            {
            [self.owner setValue:theOutletObject forKey:key];
            }
        @catch (NSException *exception)
            {
            NSLog(@"ERROR: Could not find an outlet property called %@ on %@", key, self.owner);
            }
        }];

	return(YES);
	}

#pragma mark -

- (void)prepare
    {
	self.owner = NULL;
	self.objectsByID = [NSMutableDictionary dictionary];
    self.outletIDs = [NSMutableDictionary dictionary];
    }

#pragma mark -

- (id)objectWithSpecificationDictionary:(NSDictionary *)inSpecification error:(NSError **)outError
	{
	NSString *theID = inSpecification[@"id"];
	NSString *theClassName = inSpecification[@"class"];
	Class theClass = [self classWithString:theClassName error:outError];
	if (theClass == NULL)
		{
		NSLog(@"ERROR: Failed to load class of type %@ (%@)", theClassName, inSpecification);
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
		if ([@[@"id", @"class", @"subviews", @"constraints", @"action", @"target", @"outlet"] containsObject:key])
			{
//            NSLog(@"DEBUG: Skipping %@", key);
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
		id theChild = [self objectWithSpecificationDictionary:theChildSpecification error:outError];

		if (theChild == NULL || [inObject isKindOfClass:[UIView class]] == NO || [theChild isKindOfClass:[UIView class]] == NO)
			{
            if (outError)
                {
                *outError = [self errorWithCode:-1 localizedDescription:@"Could not create view to insert into subviews." userInfo:NULL];
                }
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

    id theOutlet = theSpecification[@"outlet"];
    if (theOutlet != NULL)
        {
        // TODO this is a bit of a hack. Outlets are either strings (name of the outlet) or true (the name of the outlet is the same as the object id).
        if ([theOutlet isKindOfClass:[NSString class]] == NO)
            {
            theOutlet = theID;
            }
        self.outletIDs[theOutlet] = theID;
        }

	// #########################################################################

	NSString *theActionName = theSpecification[@"action"];
	if (theActionName.length > 0)
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
        if (outError)
            {
            *outError = [self errorWithCode:-1 localizedDescription:[NSString stringWithFormat:@"Could not create a value from %@", inValue] userInfo:NULL];
            }
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
		id theNewValue = [self objectOfType:theType withObject:theValue error:NULL];
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
        if (outError)
            {
            *outError = [self errorWithCode:-1 localizedDescription:[NSString stringWithFormat:@"Exception caught trying to set %@ to %@ on %@", theKey, theValue, inObject] userInfo:NULL];
            }
		return(NO);
		}
	return(YES);
	}

- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject error:(NSError **)outError
    {
    id theObject = [self.typeConverter objectOfType:inDestinationType withObject:inSourceObject error:outError];
    if (theObject == NULL)
        {
        theObject = [self.context.typeConverter objectOfType:inDestinationType withObject:inSourceObject error:outError];
        }
    return(theObject);
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
    NSParameterAssert(inObject != NULL);
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
	NSDictionary *theOptionsByName = @{
		@"left": @(NSLayoutFormatAlignAllLeft),
		@"right": @(NSLayoutFormatAlignAllRight),
		@"top": @(NSLayoutFormatAlignAllTop),
		@"bottom": @(NSLayoutFormatAlignAllBottom),
		@"leading": @(NSLayoutFormatAlignAllLeading),
		@"trailing": @(NSLayoutFormatAlignAllTrailing),
		@"center-x": @(NSLayoutFormatAlignAllCenterX),
		@"center-y": @(NSLayoutFormatAlignAllCenterY),
		@"baseline": @(NSLayoutFormatAlignAllBaseline),
		};

//    NSLayoutFormatDirectionLeadingToTrailing = 0 << 16, // default
//    NSLayoutFormatDirectionLeftToRight = 1 << 16,
//    NSLayoutFormatDirectionRightToLeft = 2 << 16,  

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
			NSLayoutFormatOptions theOptions = [theOptionsByName[theOptionsString] integerValue];
			theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:theFormat options:theOptions metrics:self.specification[@"metrics"] views:self.objectsByID];
			}
		else if ([theSpecification isKindOfClass:[NSDictionary class]])
			{
			NSString *theFormat = theSpecification[@"format"];

			NSString *theOptionsString = theSpecification[@"options"];
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
	else if (theSpecification[@"relationship"])
		{
		id theValue = theSpecification[@"relationship"];
		if (IS_STRING(theValue))
			{
			NSLayoutConstraint *theConstraint = [NSLayoutConstraint constraintWithRelationshipInString:theValue views:self.objectsByID];
			theConstraints = @[theConstraint];
			}
		}
	else
		{
		NSLog(@"ERROR: Do not understand constraint: %@", inObject);
        return(NULL);
		}
	return(theConstraints);
	}

- (NSError *)errorWithCode:(NSInteger)inCode localizedDescription:(NSString *)inLocalizedDescription userInfo:(NSDictionary *)inUserInfo
    {
    NSMutableDictionary *theUserInfo = [inUserInfo mutableCopy] ?: [NSMutableDictionary dictionary];
    theUserInfo[NSLocalizedDescriptionKey] = inLocalizedDescription;
    NSError *theError = [NSError errorWithDomain:@"TODO_DOMAIN" code:inCode userInfo:theUserInfo];
    NSLog(@"ERROR: %@", theError);
    return(theError);
    }

@end
