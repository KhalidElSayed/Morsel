//
//  CRemoteMorselContext.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorselContext.h"

@interface CRemoteMorselContext : CMorselContext
@property (readwrite, nonatomic, strong) NSURL *URL;
@end
