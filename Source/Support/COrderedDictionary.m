//
//  COrderedDictionary.m
//  Morsel
//
//  Created by Jonathan Wight on 1/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "COrderedDictionary.h"

@interface COrderedDictionary ()
@property (readwrite, nonatomic, copy) NSMutableDictionary *dict;
@property (readwrite, nonatomic, copy) NSMutableArray *orderedKeys;
@end

#pragma mark -

@implementation COrderedDictionary

- (id)initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
	{
    if ((self = [super init]) != NULL)
        {
		_dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys count:cnt];
        }
    return self;
    }

- (NSUInteger)count
	{
    return([_dict count]);
	}

- (id)objectForKey:(id)aKey
	{
	return([_dict objectForKey:aKey]);
	}

- (NSEnumerator *)keyEnumerator
	{
    return([_dict keyEnumerator]);
	}

- (void)removeObjectForKey:(id)aKey
    {
    [_dict removeObjectForKey:aKey];
    [_orderedKeys removeObject:aKey]; // TODO Linear!
    }

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
    {
    if ([_dict objectForKey:aKey] == NULL)
        {
        [_orderedKeys addObject:aKey];
        }

    [_dict setObject:anObject forKey:aKey];
    }

#pragma mark -

- (NSArray *)orderedValues
    {
    NSMutableArray *theValues = [NSMutableArray array];
    for (id theKey in self.orderedKeys)
        {
        [theValues addObject:[_dict objectForKey:theKey]];
        }
    return([theValues copy]);
    }

@end
