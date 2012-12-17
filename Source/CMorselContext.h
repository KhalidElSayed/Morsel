//
//  CMorselContext.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTypeConverter;

@interface CMorselContext : NSObject

@property (readonly, nonatomic, strong) CTypeConverter *typeConverter;
@property (readonly, nonatomic, strong) NSMutableArray *propertyHandlers;

+ (CMorselContext *)defaultContext;

- (UIImage *)imageNamed:(NSString *)inName;

@end
