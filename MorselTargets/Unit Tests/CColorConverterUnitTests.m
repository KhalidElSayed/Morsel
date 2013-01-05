//
//  CColorConverterUnitTests.m
//  Morsel
//
//  Created by Jonathan Wight on 1/3/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CColorConverterUnitTests.h"

#import "CColorConverter.h"

@implementation CColorConverterUnitTests

- (void)test1
	{
//	CTypeConverter *theConverter = [[CTypeConverter alloc] init];
//	[theConverter addConverterForSourceClass:[NSString class] destinationClass:[NSURL class] block:^id(id inValue, NSError *__autoreleasing *outError) {
//		return([NSURL URLWithString:inValue]);
//		}];
//
//	NSError *theError = NULL;
//
//	id theSourceObject = NULL;
//	Class theDestinatinationClass = NULL;
//	id theExpectedResult = NULL;
//	id theResult = NULL;
//	//
//	theSourceObject = @"http://twitter.com/";
//	theDestinatinationClass = [NSURL class];

    CColorConverter *theColorConverter = [[CColorConverter alloc] init];
    NSError *theError = NULL;
    NSLog(@"%@", [theColorConverter colorDictionaryWithString:@"rgba(1, 1, 1, 50%)" error:&theError]);

    }

@end
