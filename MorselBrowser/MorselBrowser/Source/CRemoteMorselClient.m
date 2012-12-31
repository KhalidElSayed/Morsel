//
//	CMorselClient.m
//	Morsel
//
//	Created by Jonathan Wight on 12/8/12.
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

#import "CRemoteMorselClient.h"

#import "CMorsel.h"

#import "CRemoteMorselContext.h"

@interface CRemoteMorselClient () <NSNetServiceDelegate>
@property (readwrite, nonatomic, strong) NSData *lastData;
@end

@implementation CRemoteMorselClient

- (void)start
	{
	if (self.URL != NULL)
		{
		[self fetch];
		}
	else if (self.service != NULL)
		{
		NSLog(@"RESOLVING URL");
		//
		self.service.delegate = self;
		[self.service resolveWithTimeout:10.0];
		}

	}

- (void)fetch
	{
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringCacheData
      timeoutInterval:0.0];

	[NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
		if (theResponse.statusCode == 200)
			{
			if ([data isEqualToData:self.lastData] == NO)
				{
				NSLog(@"Change detected… loading…");

				CRemoteMorselContext *theContext = [[CRemoteMorselContext alloc] init];
				theContext.URL = self.URL;
				CMorsel *theMorsel = [[CMorsel alloc] initWithData:data error:NULL];
				theMorsel.context = theContext;
				if (self.morselHandler)
					{
					self.morselHandler(theMorsel, NULL);
					}
				self.lastData = data;
				}
			}

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[self fetch];
			});
		}];
	}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
	{
	NSDictionary *theDictionary = [NSNetService dictionaryFromTXTRecordData:sender.TXTRecordData];
	if (theDictionary[@"url"] != NULL)
		{
		NSString *theURLString = [[NSString alloc] initWithData:theDictionary[@"url"] encoding:NSUTF8StringEncoding];
		self.URL = [NSURL URLWithString:theURLString];
		}
	else if (theDictionary[@"path"] != NULL)
		{
		NSString *thePath = [[NSString alloc] initWithData:theDictionary[@"path"] encoding:NSUTF8StringEncoding];
		NSString *theScheme = @"http";
		if (theDictionary[@"scheme"] != NULL)
			{
			theScheme = [[NSString alloc] initWithData:theDictionary[@"scheme"] encoding:NSUTF8StringEncoding];
			}

		self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", sender.hostName, sender.port, thePath]];
		}

	NSLog(@"> %@", self.URL);

	[self start];
	}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
	{
	NSLog(@"DID NOT RESOLVE: %@", errorDict);
	}




@end
