//
//	CTypeConverter.m
//	Morsel
//
//	Created by Jonathan Wight on 12/12/12.
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

- (void)addConverterForSourceType:(NSString *)inSourceType destinationType:(NSString *)inDestinationType block:(TypeConverterBlock)inBlock;
	{
	NSArray *theKey = @[ inSourceType, inDestinationType ];
	self.converters[theKey] = [inBlock copy];
	}

- (void)addConverterForSourceClass:(Class)inSourceClass destinationClass:(Class)inDestinationClass block:(TypeConverterBlock)inBlock;
	{
	NSString *theSourceType = [self typeForClass:inSourceClass createMapping:YES];
	NSString *theDestinationType = [self typeForClass:inDestinationClass createMapping:YES];
	[self addConverterForSourceType:theSourceType destinationType:theDestinationType block:inBlock];
	}

- (void)addConverterForSourceClass:(Class)inSourceClass destinationType:(NSString *)inDestinationType block:(TypeConverterBlock)inBlock;
	{
	NSString *theSourceType = [self typeForClass:inSourceClass createMapping:YES];
	[self addConverterForSourceType:theSourceType destinationType:inDestinationType block:inBlock];
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
	
	TypeConverterBlock theBlock = self.converters[theKey];
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
