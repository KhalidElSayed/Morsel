//
//	CMorselSession.m
//	Morsel
//
//	Created by Jonathan Wight on 12/12/12.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "CMorselSession.h"

#import "MorselSupport.h"
#import "MorselAsserts.h"

#import "CTypeConverter.h"
#import "CYAMLDeserializer.h"
#import "CMorselContext.h"
#import "CMorselGlobalContext.h"

#if !defined(USE_DEBUG_DICTIONARY)
#define USE_DEBUG_DICTIONARY 0
#endif

#if USE_DEBUG_DICTIONARY == 1
#import "CDebugYAMLDeserializer.h"
#endif

@interface CMorselSession ()
@property (readwrite, nonatomic, strong) NSCache *deserializedObjectsCache;
@end

#pragma mark -

@implementation CMorselSession

static CMorselSession *gSharedInstance = NULL;

+ (CMorselSession *)defaultSession
    {
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
        gSharedInstance = [[CMorselSession alloc] init];
        });
    return(gSharedInstance);
    }

#pragma mark -

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
		#if USE_DEBUG_DICTIONARY == 1
		_deserializer = [[CDebugYAMLDeserializer alloc] init];
		#else
		_deserializer = [[CYAMLDeserializer alloc] init];
		#endif

        // TODO This is YAML only and wont work for plists and other formats...
		[_deserializer registerHandlerForTag:@"!UIColor" block:^id (id value, NSError *__autoreleasing *error) {
			UIColor *theColor = [self.context.typeConverter objectOfClass:[UIColor class] withObject:value error:error];
			return(theColor);
			}];

		NSError *theError = NULL;
		if ([self setup:&theError] == NO)
			{
			NSLog(@"ERROR: Could not create CMorselSession due to: %@", theError);
			self = NULL;
			}
        }
    return self;
    }

- (BOOL)setup:(NSError **)outError
	{
	// #########################################################################

	NSURL *theGlobalSpecificationURL = [[NSBundle mainBundle] URLForResource:@"global" withExtension:@"morsel"];
	NSDictionary *theGlobalSpecification = [self deserializeObjectWithURL:theGlobalSpecificationURL error:outError];
	if (theGlobalSpecification == NULL)
		{
		return(NO);
		}

    self.context = [[CMorselGlobalContext alloc] initWithSpecification:theGlobalSpecification error:outError];
	if (self.context == NULL)
		{
		return(NO);
		}
    // TODO error checking...
    [self.context load:outError];

	return(YES);
	}

#pragma mark -

- (id)deserializeObjectWithData:(NSData *)inData error:(NSError **)outError
    {
    // TODO -- what about plists huh? huh? huh?
    id theDeserializedObject = [self.deserializer deserializeData:inData error:outError];
    return(theDeserializedObject);
    }

- (id)deserializeObjectWithURL:(NSURL *)inURL error:(NSError **)outError
	{
	NSParameterAssert(inURL != NULL);

	id theDeserializedObject = [self.deserializedObjectsCache objectForKey:inURL];
	if (theDeserializedObject == NULL)
		{
//		NSLog(@"CACHE MISS: %@", inURL);
        if ([[inURL pathExtension] isEqualToString:@"morsel"])
            {
            theDeserializedObject = [self.deserializer deserializeURL:inURL error:outError];
            }
        else if ([[inURL pathExtension] isEqualToString:@"plist"])
            {
            theDeserializedObject = [NSDictionary dictionaryWithContentsOfURL:inURL];
            }
		if (theDeserializedObject == NULL)
			{
			return(NULL);
			}
		[self.deserializedObjectsCache setObject:theDeserializedObject forKey:inURL];
		}
	else
		{
//		NSLog(@"CACHE HIT: %@", inURL);
		}
	return(theDeserializedObject);
	}

@end
