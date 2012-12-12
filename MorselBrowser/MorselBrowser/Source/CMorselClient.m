//
//  CMorselClient.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorselClient.h"

#import "CMorsel.h"

@interface CMorselClient () <NSNetServiceDelegate>
@end

@implementation CMorselClient

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
	NSLog(@"FETCHING");

	NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringCacheData
      timeoutInterval:0.0];

	[NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSLog(@"SUCCESS");
		NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
		if (theResponse.statusCode == 200)
			{
			CMorsel *theMorsel = [[CMorsel alloc] initWithData:data error:NULL];
			if (self.morselHandler)
				{
				self.morselHandler(theMorsel, NULL);
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
	NSURL *theURL = NULL;
	if (theDictionary[@"url"] != NULL)
		{
		NSString *theURLString = [[NSString alloc] initWithData:theDictionary[@"url"] encoding:NSUTF8StringEncoding];
		theURL = [NSURL URLWithString:theURLString];
		}
	else if (theDictionary[@"path"] != NULL)
		{
		NSString *thePath = [[NSString alloc] initWithData:theDictionary[@"path"] encoding:NSUTF8StringEncoding];
		NSString *theScheme = @"http";
		if (theDictionary[@"scheme"] != NULL)
			{
			theScheme = [[NSString alloc] initWithData:theDictionary[@"scheme"] encoding:NSUTF8StringEncoding];
			}

		theURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", sender.hostName, sender.port, thePath]];
		}

	[self start];
	}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
	{
	NSLog(@"DID NOT RESOLVE: %@", errorDict);
	}




@end
