//
//  CDebugDictionary.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 1/1/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CDebugDictionary.h"

@interface CDebugDictionary ()
@property (readwrite, nonatomic, copy) NSDictionary *dict;
@property (readwrite, nonatomic, strong) NSCountedSet *accessCounts;
@end

#pragma mark -

@implementation CDebugDictionary

- (id)initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
	{
    if ((self = [super init]) != NULL)
        {
		_dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:cnt];
		_accessCounts = [NSCountedSet set];
        }
    return self;
    }

- (void)dealloc
	{
	for (id theKey in [_dict allKeys])
		{
		if ([_accessCounts countForObject:theKey] == 0)
			{
			NSLog(@"Zero accesses for key '%@' in dictionary %p", theKey, self);
			}
		}
	}

- (NSUInteger)count
	{
    return([_dict count]);
	}

- (id)objectForKey:(id)aKey
	{
	id theObject = [self.dict objectForKey:aKey];
	if (theObject != NULL)
		{
		[self.accessCounts addObject:aKey];
		}
	return(theObject);
	}

- (NSEnumerator *)keyEnumerator
	{
    return([_dict keyEnumerator]);
	}

@end
