//
//	CMorselContext.h
//	Morsel
//
//	Created by Jonathan Wight on 2/2/13.
//	Copyright 2013 Jonathan Wight. All rights reserved.
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

#import <Foundation/Foundation.h>

#import "CMorselSession.h"

@class CTypeConverter;

typedef BOOL (^MorselPropertyHandler)(id object, NSString *property, id specification, NSError **outError);

@interface CMorselContext : NSObject

@property (readwrite, nonatomic, strong) CMorselContext *nextContext;
@property (readonly, nonatomic, strong) CTypeConverter *typeConverter;
@property (readonly, nonatomic, strong) NSMutableArray *propertyHandlers;
@property (readonly, nonatomic, strong) NSArray *propertyTypes;
@property (readonly, nonatomic, strong) NSArray *defaults;

- (id)initWithSpecification:(NSDictionary *)inSpecification error:(NSError **)outError;

- (BOOL)load:(NSError **)outError;

- (Class)classWithString:(NSString *)inString error:(NSError **)outError;

- (void)addPropertyHandlerForPredicate:(NSPredicate *)inPredicate block:(MorselPropertyHandler)inBlock;

- (NSPredicate *)predicateForClass:(Class)inClass property:(NSString *)inProperty;
- (id)objectOfType:(NSString *)inDestinationType withObject:(id)inSourceObject error:(NSError **)outError;
- (NSDictionary *)typeForObject:(id)inObject propertyName:(NSString *)inPropertyName;
- (MorselPropertyHandler)handlerForObject:(id)inObject keyPath:(NSString *)inKeyPath;
- (NSDictionary *)defaultsForObjectOfID:(NSString *)inID class:(Class)inClass;

@end
