//
//  CRemoteMorselContext.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CRemoteMorselContext.h"

@implementation CRemoteMorselContext

- (UIImage *)imageNamed:(NSString *)inName;
	{
	// TODO -- this is a bit of a hack. On a local network it works fine though. But shouldn't like UIImage data sync.
	NSURL *theURL = [NSURL URLWithString:inName relativeToURL:self.URL];
	theURL = [theURL absoluteURL];
	NSData *theData = [NSData dataWithContentsOfURL:theURL];
	UIImage *theImage = [UIImage imageWithData:theData];
	return(theImage);
	}

@end
