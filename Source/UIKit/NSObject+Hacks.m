//
//  NSObject+Hacks.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/13/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "NSObject+Hacks.h"

#import <objc/runtime.h>

@implementation NSObject (Hacks)

//- (void)setPropertyValue:(id)value forKey:(NSString *)key
//	{
//	objc_property_t theProperty = class_getProperty([self class], [key UTF8String]);
//	if (theProperty)
//		{
//		unsigned int theCount = 0;
//		objc_property_attribute_t *theAttributes = property_copyAttributeList(theProperty, &theCount);
//		for (int N = 0; N != theCount; ++N)
//			{
//			NSLog(@"%s: %s", theAttributes[N].name, theAttributes[N].value);
//			}
//		}
//
////class_copyProtocolList([value], <#unsigned int *outCount#>)
//
////protocol_getProperty(<#Protocol *proto#>, [key UTF8String], <#BOOL isRequiredProperty#>, <#BOOL isInstanceProperty#>)
//
//
//	}

@end
