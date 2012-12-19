//
//  CMorsel.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMorselContext;

@interface CMorsel : NSObject

@property (readwrite, nonatomic, strong) CMorselContext *context;

- (id)initWithData:(NSData *)inData error:(NSError **)outError;
- (id)initWithURL:(NSURL *)inURL error:(NSError **)outError;
- (id)initWithName:(NSString *)inName bundle:(NSBundle *)inBundle error:(NSError **)outError;

- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil error:(NSError **)outError;

@end
