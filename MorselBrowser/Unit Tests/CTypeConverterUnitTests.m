//
//  Unit_Tests.m
//  Unit Tests
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CTypeConverterUnitTests.h"

#import "CTypeConverter.h"

@interface CTypeConverterUnitTests ()
@end

#pragma mark -

@implementation CTypeConverterUnitTests

- (void)setUp
	{
    [super setUp];
	}

- (void)tearDown
	{
    [super tearDown];
	}

- (void)test1
	{
	CTypeConverter *theConverter = [[CTypeConverter alloc] init];
	[theConverter addConverterForSourceClass:[NSString class] destinationClass:[NSURL class] block:^id(id inValue, NSError *__autoreleasing *outError) {
		return([NSURL URLWithString:inValue]);
		}];

	NSError *theError = NULL;

	id theSourceObject = NULL;
	Class theDestinatinationClass = NULL;
	id theExpectedResult = NULL;
	id theResult = NULL;
	//
	theSourceObject = @"http://twitter.com/";
	theDestinatinationClass = [NSURL class];
	theExpectedResult = [NSURL URLWithString:theSourceObject];
	theResult = [theConverter objectOfClass:theDestinatinationClass withObject:theSourceObject error:&theError];
	STAssertEqualObjects(theResult, theExpectedResult, @"TODO");
	//
	theSourceObject = [@"http://twitter.com/" mutableCopy];
	theDestinatinationClass = [NSURL class];
	theExpectedResult = [NSURL URLWithString:theSourceObject];
	theResult = [theConverter objectOfClass:theDestinatinationClass withObject:theSourceObject error:&theError];
	STAssertEqualObjects(theResult, theExpectedResult, @"TODO");
	//
	theSourceObject = [NSURL URLWithString:@"http://twitter.com/"];
	theDestinatinationClass = [NSURL class];
	theExpectedResult = theSourceObject;
	theResult = [theConverter objectOfClass:theDestinatinationClass withObject:theSourceObject error:&theError];
	STAssertEqualObjects(theResult, theExpectedResult, @"TODO");

	}

@end
