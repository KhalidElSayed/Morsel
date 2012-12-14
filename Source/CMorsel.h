//
//  CMorsel.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMorsel : NSObject

@property (readonly, nonatomic, strong) id rootObject;

- (id)initWithData:(NSData *)inData error:(NSError **)outError;
- (id)initWithURL:(NSURL *)inURL error:(NSError **)outError;

- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil;

@end
