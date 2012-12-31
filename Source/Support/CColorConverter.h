//
//  UIColor+Conveniences.h
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CColorConverter : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)colorDictionaryWithString:(NSString *)inString error:(NSError **)outError;

@end

#pragma mark -

#if TARGET_OS_IPHONE == 1

@interface CColorConverter (UIColor)
- (UIColor *)colorWithString:(NSString *)inString error:(NSError **)outError;
@end

@interface UIColor (CColorConverter)
+ (UIColor *)colorWithString:(NSString *)inString error:(NSError **)outError;
@end

#endif /* TARGET_OS_IPHONE == 1 */
