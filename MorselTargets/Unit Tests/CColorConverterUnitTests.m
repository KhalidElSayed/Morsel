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
    CColorConverter *theColorConverter = [[CColorConverter alloc] init];
    NSError *theError = NULL;
    NSString *theColorString = @"rgba(255, 255, 255, 50%)";
    NSDictionary *theResult = [theColorConverter colorDictionaryWithString:theColorString error:&theError];
    NSDictionary *theExpectedResult = @{ @"type": @"RGB", @"red": @(1.0), @"green": @(1.0), @"blue": @(1.0), @"alpha": @(0.5) };
    STAssertEqualObjects(theResult, theExpectedResult, NULL);
    }

- (void)test2
	{
    CColorConverter *theColorConverter = [[CColorConverter alloc] init];
    NSError *theError = NULL;
    NSString *theColorString = @"rgb(255, 255, 255)";
    NSDictionary *theResult = [theColorConverter colorDictionaryWithString:theColorString error:&theError];
    NSDictionary *theExpectedResult = @{ @"type": @"RGB", @"red": @(1.0), @"green": @(1.0), @"blue": @(1.0), @"alpha": @(1.0) };
    STAssertEqualObjects(theResult, theExpectedResult, NULL);
    }

@end
