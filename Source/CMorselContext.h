//
//  CMorselContext.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTypeConverter;

typedef BOOL (^MorselPropertyHandler)(id object, NSString *property, id specification, NSError **outError);

/// CMorselContexts are global objects used to configure and extend morsel processing.
@interface CMorselContext : NSObject

@property (readonly, nonatomic, strong) CTypeConverter *typeConverter;
@property (readonly, nonatomic, strong) NSMutableArray *propertyHandlers;
@property (readonly, nonatomic, strong) NSArray *defaults;
@property (readonly, nonatomic, strong) NSDictionary *classSynonyms;
@property (readonly, nonatomic, strong) NSArray *propertyTypes;

+ (CMorselContext *)defaultContext;

- (UIImage *)imageNamed:(NSString *)inName;

- (void)addPropertyHandlerForPredicate:(NSPredicate *)inPredicate block:(MorselPropertyHandler)inBlock;

@end
