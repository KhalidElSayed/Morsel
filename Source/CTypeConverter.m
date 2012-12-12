//
//  CTypeConverter.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CTypeConverter.h"

@interface CTypeConverter ()
@property (readwrite, nonatomic, strong) NSMutableDictionary *converters;
@property (readwrite, nonatomic, strong) NSMutableDictionary *classMappings;
@end

#pragma mark -

@implementation CTypeConverter

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
		_converters = [NSMutableDictionary dictionary];
		_classMappings = [NSMutableDictionary dictionary];
        }
    return self;
    }

#pragma mark -

- (void)addConverterForSourceType:(NSString *)inSourceType destinationType:(NSString *)inDestinationType block:(id (^)(id inValue, NSError **outError))inBlock;
	{
	NSArray *theKey = @[ inSourceType, inDestinationType ];
	self.converters[theKey] = [inBlock copy];
	}

- (void)addConverterForSourceClass:(Class)inSourceClass destinationClass:(Class)inDestinationClass block:(id (^)(id inValue, NSError **outError))inBlock;
	{
	NSString *theSourceType = [self typeForClass:inSourceClass createMapping:YES];
	NSString *theDestinationType = [self typeForClass:inDestinationClass createMapping:YES];
	[self addConverterForSourceType:theSourceType destinationType:theDestinationType block:inBlock];
	}

#pragma mark -

- (id)objectOfClass:(Class)inDestinationClass withObject:(id)inSourceObject error:(NSError **)outError
	{
	NSString *theDestinationType = [self typeForClass:inDestinationClass];
	id theObject = [self objectOfType:theDestinationType withObject:inSourceObject error:outError];
	return(theObject);
	}

- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject error:(NSError **)outError
	{
	NSString *theSourceType = [self typeForObject:inSourceObject createMapping:YES];
	if (theSourceType == NULL)
		{
		if (outError != NULL)
			{
			*outError = [NSError errorWithDomain:@"TODO" code:-1 userInfo:NULL];
			}
		return(NULL);
		}
	id theObject = [self objectOfType:inDestinationType withObject:inSourceObject ofType:theSourceType error:outError];
	return(theObject);
	}

- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject ofType:(NSString *)inSourceType error:(NSError **)outError
	{
	if ([inSourceType isEqualToString:inDestinationType])
		{
		return(inSourceObject);
		}

	NSArray *theKey = @[ inSourceType, inDestinationType ];
	
	id (^theBlock)(id inValue, NSError **outError) = self.converters[theKey];
	if (theBlock == NULL)
		{
		if (outError != NULL)
			{
			*outError = [NSError errorWithDomain:@"TODO" code:-1 userInfo:NULL];
			}
		return(NULL);
		}
	id theObject = theBlock(inSourceObject, outError);
	return(theObject);
	}

#pragma mark -

- (NSString *)typeForClass:(Class)inClass createMapping:(BOOL)inCreateMapping
	{
	NSString *theClassName = NSStringFromClass(inClass);
	NSString *theTypeName = self.classMappings[theClassName];
	if (theTypeName == NULL && inCreateMapping == YES)
		{
		theTypeName = [NSString stringWithFormat:@"class:%@", theClassName];
		self.classMappings[theClassName] = theTypeName;
		}
	return(theTypeName);
	}

- (NSString *)typeForClass:(Class)inClass
	{
	return([self typeForClass:inClass createMapping:NO]);
	}

- (NSString *)typeForObject:(id)inObject createMapping:(BOOL)inCreateMapping
	{
	Class theOriginalClass = [inObject class];
	NSString *theType = [self typeForClass:theOriginalClass createMapping:NO];
	if (theType)
		{
		return(theType);
		}

	Class theClass = [theOriginalClass superclass];
	while (theClass != NULL)
		{
		theType = [self typeForClass:theClass createMapping:NO];
		if (theType != NULL)
			{
			if (inCreateMapping == YES)
				{
				self.classMappings[NSStringFromClass(theOriginalClass)] = theType;
				}
			break;
			}

		theClass = [theClass superclass];
		}

	return(theType);
	}

- (NSString *)typeForObject:(id)inObject
	{
	return([self typeForObject:inObject createMapping:NO]);
	}

@end
