//
//  CMorselContext.m
//	Morsel
//
//	Created by Jonathan Wight on 2/2/13.
//	Copyright 2013 Jonathan Wight. All rights reserved.
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

#import "CMorselContext.h"

#import "MorselAsserts.h"
#import "CTypeConverter.h"
#import "CMorselSession.h"

@interface CMorselContext ()
@property (readwrite, nonatomic, strong) NSDictionary *specification;
@property (readwrite, nonatomic, strong) NSCache *cache;

@end

@implementation CMorselContext

@synthesize propertyTypes = _propertyTypes;
@synthesize defaults = _defaults;

- (id)initWithSpecification:(NSDictionary *)inSpecification error:(NSError **)outError;
    {
    if ((self = [super init]) != NULL)
        {
        _specification = inSpecification;
		_typeConverter = [[CTypeConverter alloc] init];
		_propertyHandlers = [NSMutableArray array];
		_cache = [[NSCache alloc] init];
        }
    return self;
    }

- (BOOL)load:(NSError **)outError;
    {
    // Load enumerations...
	NSDictionary *theEnumerations = self.specification[@"enums"];
	[theEnumerations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

		NSString *theEnumerationName = key;
		NSDictionary *theEnumerationKeyValues = obj;
		NSString *theEnumerationType = [NSString stringWithFormat:@"enum:%@", theEnumerationName];

		[self.typeConverter addConverterForSourceClass:[NSString class] destinationType:theEnumerationType block:^id(id inValue, NSError *__autoreleasing *outError_) {
			id theValue = theEnumerationKeyValues[inValue];
			if (theValue == NULL)
				{
				AssertUnimplemented_();
				}
			return(theValue);
			}];

		[self.typeConverter addConverterForSourceClass:[NSNumber class] destinationType:theEnumerationType block:^id(id inValue, NSError *__autoreleasing *outError_) {
			return(inValue);
			}];
		}];

	return(YES);
	}

#pragma mark -

- (NSArray *)propertyTypes
	{
	if (_propertyTypes == NULL)
		{
		NSMutableArray *thePropertyTypes = [NSMutableArray array];

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

- (NSArray *)defaults
	{
	if (_defaults == NULL)
		{
		_defaults = self.specification[@"defaults"];
		}
	return(_defaults);
	}

#pragma mark -

- (Class)classWithString:(NSString *)inString error:(NSError **)outError
	{
	Class theClass = NSClassFromString(inString);
	return(theClass);
	}

- (void)addPropertyHandlerForPredicate:(NSPredicate *)inPredicate block:(MorselPropertyHandler)inBlock
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

- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject error:(NSError **)outError
    {
    id theObject = [self.typeConverter objectOfType:inDestinationType withObject:inSourceObject error:outError];
    if (theObject == NULL)
        {
        theObject = [self.nextContext objectOfType:inDestinationType withObject:inSourceObject error:outError];
        }
    return(theObject);
    }

- (NSDictionary *)typeForObject:(id)inObject propertyName:(NSString *)inPropertyName
	{
    NSParameterAssert(inObject != NULL);
	NSDictionary *theType = NULL;

	NSString *theKey = [NSString stringWithFormat:@"propertyType:%@.%@", NSStringFromClass([inObject class]), inPropertyName];

	theType = [self.cache objectForKey:theKey];
	if (theType == NULL)
		{
		// Search for the type...
		NSDictionary *theEvaluator = @{
			@"class": [inObject class],
			@"property": inPropertyName
			};
		for (NSDictionary *thePropertyType in self.propertyTypes)
			{
			NSPredicate *thePredicate = thePropertyType[@"predicate"];
			if ([thePredicate evaluateWithObject:theEvaluator] == YES)
				{
				theType = thePropertyType[@"type"];
				break;
				}
			}

		// If we still don't have a type look in the nextContext...
		if (theType == NULL)
			{
			theType = [self.nextContext typeForObject:inObject propertyName:inPropertyName];
			}

		if (theType != NULL)
			{
			[self.cache setObject:theType forKey:theKey];
			}
		}

	return(theType);
	}

- (MorselPropertyHandler)handlerForObject:(id)inObject keyPath:(NSString *)inKeyPath
    {
	NSDictionary *theTestDictionary = @{
		@"class": [inObject class],
		@"property": inKeyPath
		};

	for (NSDictionary *theDictionary in self.allPropertyHandlers)
		{
		NSPredicate *thePredicate = theDictionary[@"predicate"];
		if ([thePredicate evaluateWithObject:theTestDictionary] == YES)
			{
			MorselPropertyHandler theBlock = theDictionary[@"block"];
			return(theBlock);
			}
		}

    return(NULL);
    }

- (NSDictionary *)defaultsForObjectOfID:(NSString *)inID class:(Class)inClass;
    {
	NSMutableDictionary *theDefaultSpecification = [NSMutableDictionary dictionary];

    CMorselContext *theContext = self;
    while (theContext != NULL)
        {
        for (NSDictionary *theDefault in theContext.defaults)
            {
            if ([theDefault[@"ids"] containsObject:inID])
                {
                [theDefaultSpecification addEntriesFromDictionary:theDefault];
                [theDefaultSpecification removeObjectForKey:@"ids"];
                }
            else if ([inClass isSubclassOfClass:[self classWithString:theDefault[@"class"] error:NULL]])
                {
                [theDefaultSpecification addEntriesFromDictionary:theDefault];
                [theDefaultSpecification removeObjectForKey:@"ids"];
                }
            }

        theContext = theContext.nextContext;
        }

    return(theDefaultSpecification);
    }

#pragma mark -

- (NSArray *)allPropertyHandlers
    {
    NSMutableArray *thePropertyHandlers = [NSMutableArray array];
    [thePropertyHandlers addObjectsFromArray:self.propertyHandlers];
    if (self.nextContext)
        {
        [thePropertyHandlers addObjectsFromArray:self.nextContext.allPropertyHandlers];
        }
    return(thePropertyHandlers);
    }

@end
