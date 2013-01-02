//
//  COrderedDictionary.h
//  Morsel
//
//  Created by Jonathan Wight on 1/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COrderedDictionary : NSMutableDictionary

- (NSArray *)orderedKeys;
- (NSArray *)orderedValues;

@end

