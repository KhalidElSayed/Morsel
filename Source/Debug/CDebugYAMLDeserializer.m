//
//  CDebugYAMLDeserializer.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 1/1/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CDebugYAMLDeserializer.h"

#import "CDebugDictionary.h"

@implementation CDebugYAMLDeserializer

- (id)finalizeMappingObject:(id)inObject;
	{
	return([[CDebugDictionary alloc] initWithDictionary:inObject]);
	}

@end
