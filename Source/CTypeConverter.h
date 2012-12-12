//
//  CTypeConverter.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTypeConverter : NSObject

- (void)addConverterForSourceType:(NSString *)inSourceType destinationType:(NSString *)inDestinationType block:(id (^)(id inValue, NSError **outError))inBlock;
- (void)addConverterForSourceClass:(Class)inSourceClass destinationClass:(Class)inDestinationClass block:(id (^)(id inValue, NSError **outError))inBlock;

- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject error:(NSError **)outError;
- (id)objectOfClass:(Class)inDestinationClass withObject:(id)inSourceObject error:(NSError **)outError;

@end
