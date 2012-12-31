//
//	Unit_Tests.m
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
