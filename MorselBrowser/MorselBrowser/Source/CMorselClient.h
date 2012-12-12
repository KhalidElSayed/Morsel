//
//  CMorselClient.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMorsel;

@interface CMorselClient : NSObject

@property (readwrite, nonatomic, strong) NSNetService *service;
@property (readwrite, nonatomic, strong) NSURL *URL;
@property (readwrite, nonatomic, copy) void (^morselHandler)(CMorsel *morsel, NSError *error);

- (void)start;

@end
