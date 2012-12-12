//
//  CTypeConverter.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^TypeConverterBlock)(id inValue, NSError **outError);

@interface CTypeConverter : NSObject

- (void)addConverterForSourceType:(NSString *)inSourceType destinationType:(NSString *)inDestinationType block:(TypeConverterBlock)inBlock;
- (void)addConverterForSourceClass:(Class)inSourceClass destinationClass:(Class)inDestinationClass block:(TypeConverterBlock)inBlock;

- (NSString *)typeForClass:(Class)inClass;
- (NSString *)typeForObject:(id)inObject;

- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject error:(NSError **)outError;
- (id)objectOfClass:(Class)inDestinationClass withObject:(id)inSourceObject error:(NSError **)outError;

@end
