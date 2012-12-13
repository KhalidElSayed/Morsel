//
//  UIColor+Conveniences.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "UIColor+Conveniences.h"

static CGFloat StringToFloat(NSString *inString, CGFloat base);
static int hexdec(const char *hex, int len);

@implementation UIColor (Conveniences)

+ (UIColor *)colorwithString:(NSString *)inString
	{
	// ### Find colour by color name...
	static NSDictionary *sColorNames = NULL;
	static dispatch_once_t sColorNamesOnceToken;
	dispatch_once(&sColorNamesOnceToken, ^{
		sColorNames = @{
			@"black": [UIColor blackColor],
			@"darkGray": [UIColor darkGrayColor],
			@"lightGray": [UIColor lightGrayColor],
			@"white": [UIColor whiteColor],
			@"gray": [UIColor grayColor],
			@"red": [UIColor redColor],
			@"green": [UIColor greenColor],
			@"blue": [UIColor blueColor],
			@"cyan": [UIColor cyanColor],
			@"yellow": [UIColor yellowColor],
			@"magenta": [UIColor magentaColor],
			@"orange": [UIColor orangeColor],
			@"purple": [UIColor purpleColor],
			@"brown": [UIColor brownColor],
			@"clear": [UIColor clearColor],
			};
		});

	UIColor *theColor = sColorNames[inString];
	if (theColor)
		{
		return(theColor);
		}

	// ### Find rgb(), rgba(), hsl(), and hsla() style colours with values provided as integers or percentages.
	static NSRegularExpression *sRGBRegex = NULL;
	static dispatch_once_t sRGBRegexOnceToken;
	dispatch_once(&sRGBRegexOnceToken, ^{
		NSError *error = NULL;
		sRGBRegex = [NSRegularExpression regularExpressionWithPattern:@"^(rgba?|hsla?)\\(\\s*(\\d+(?:\\.\\d+)?%?)\\s*,\\s*(\\d+(?:\\.\\d+)?%?),\\s*(\\d+(?:\\.\\d+)?%?)(?:,\\s*(\\d+(?:\\.\\d+)?%?))?\\)$" options:0 error:&error];
		});

	NSTextCheckingResult *theResult = [sRGBRegex firstMatchInString:inString options:0 range:(NSRange){ .length = inString.length }];
	if (theResult != NULL)
		{
		NSString *theType = [inString substringWithRange:[theResult rangeAtIndex:1]];
		if ([[theType substringToIndex:3] isEqualToString:@"rgb"])
			{
			CGFloat R = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:2]], 255.0);
			CGFloat G = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:3]], 255.0);
			CGFloat B = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:4]], 255.0);
			CGFloat A = 1.0;
			if ([theType isEqualToString:@"rgba"])
				{
				A = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:5]], 255.0);
				}

			theColor = [UIColor colorWithRed:R green:G blue:B alpha:A];
			}
		else if ([[theType substringToIndex:3] isEqualToString:@"hsl"])
			{
			CGFloat hue = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:2]], 360.0);
			CGFloat saturation = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:3]], 255.0);
			CGFloat brightness = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:4]], 255.0);
			CGFloat A = 1.0;
			if ([theType isEqualToString:@"hsla"])
				{
				A = StringToFloat([inString substringWithRange:[theResult rangeAtIndex:5]], 255.0);
				}

			theColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:A];
			}

		return(theColor);
		}

	// ### Find colour by hex triplets, either 3 or 6 byte (optionally preceded by a #)
	static NSRegularExpression *sHexRegex = NULL;
	static dispatch_once_t sHexRegexOnceToken;
	dispatch_once(&sHexRegexOnceToken, ^{
		NSError *error = NULL;
		sHexRegex = [NSRegularExpression regularExpressionWithPattern:@"^#?(?:([\\da-f]{3})|([\\da-f]{6}))$" options:NSRegularExpressionCaseInsensitive error:&error];
		});

	theResult = [sHexRegex firstMatchInString:inString options:0 range:(NSRange){ .length = inString.length }];
	if (theResult != NULL)
		{
		if ([theResult rangeAtIndex:1].location != NSNotFound)
			{
			NSString *theHex = [inString substringWithRange:[theResult rangeAtIndex:1]];
			int D = hexdec([theHex UTF8String], 0);
			CGFloat R = (CGFloat)((D & 0xF00) >> 8) / 15.0;
			CGFloat G = (CGFloat)((D & 0x0F0) >> 4) / 15.0;
			CGFloat B = (CGFloat)((D & 0x00F) >> 0) / 15.0;
			theColor = [UIColor colorWithRed:R green:G blue:B alpha:1.0];
			}
		else
			{
			NSString *theHex = [inString substringWithRange:[theResult rangeAtIndex:2]];
			int D = hexdec([theHex UTF8String], 0);
			CGFloat R = (CGFloat)((D & 0xFF0000) >> 16) / 255.0;
			CGFloat G = (CGFloat)((D & 0x00FF00) >> 8) / 255.0;
			CGFloat B = (CGFloat)((D & 0x00FF00) >> 0) / 255.0;
			theColor = [UIColor colorWithRed:R green:G blue:B alpha:1.0];
			}
		return(theColor);
		}

	if (theColor == NULL)
		{
		theColor = [UIColor clearColor];
		}

	return(theColor);
	}

@end

// Adapted from http://stackoverflow.com/a/11068850
/** 
 * @brief convert a hexidecimal string to a signed long
 * will not produce or process negative numbers except 
 * to signal error.
 * 
 * @param hex without decoration, case insensative. 
 * 
 * @return -1 on error, or result (max sizeof(long)-1 bits)
 */
static int hexdec(const char *hex, int len)
    {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Winitializer-overrides"
    static const int hextable[] = {
       [0 ... 255] = -1,                     // bit aligned access into this table is considerably
       ['0'] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, // faster for most modern processors,
       ['A'] = 10, 11, 12, 13, 14, 15,       // for the space conscious, reduce to
       ['a'] = 10, 11, 12, 13, 14, 15        // signed char.
    };
    #pragma clang diagnostic pop

    int ret = 0;
    if (len > 0)
        {
        while (*hex && ret >= 0 && (len--))
            {
            ret = (ret << 4) | hextable[*hex++];
            }
        }
    else
        {
        while (*hex && ret >= 0)
            {
            ret = (ret << 4) | hextable[*hex++];
            }
        }
    return ret; 
    }

static CGFloat StringToFloat(NSString *inString, CGFloat base)
	{
	if ([inString characterAtIndex:inString.length - 1] == '%')
		{
		return([[inString substringToIndex:inString.length - 1] doubleValue] / 100.0);
		}
	else
		{
		return([inString  doubleValue] / base);
		}
	}
