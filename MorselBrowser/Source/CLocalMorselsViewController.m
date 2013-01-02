//
//	CLocalMorselsViewController.m
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

#import "CLocalMorselsViewController.h"

#import "CMorselViewController.h"
#import "MorselAsserts.h"

@interface CLocalMorselsViewController ()
@property (readwrite, nonatomic, strong) NSArray *morsels;
@end

@implementation CLocalMorselsViewController

- (void)viewDidLoad
	{
    [super viewDidLoad];
	//
	NSMutableArray *theMorsels = [NSMutableArray array];
	for (NSURL *theURL in [[NSFileManager defaultManager] enumeratorAtURL:[NSBundle mainBundle].resourceURL includingPropertiesForKeys:NULL options:0 errorHandler:NULL])
		{
		if ([[theURL lastPathComponent] rangeOfString:@"_bad"].location != NSNotFound)
			{
			continue;
			}
		if ([[theURL lastPathComponent] isEqualToString:@"global.morsel"])
			{
			continue;
			}
		if ([theURL.pathExtension isEqualToString:@"morsel"])
			{
			[theMorsels addObject:theURL];
			}
		}
	self.morsels = [theMorsels copy];
	}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
    return(self.morsels.count);
	}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	cell.textLabel.text = [[self.morsels objectAtIndex:indexPath.row] lastPathComponent];
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
	{
	NSIndexPath *theIndexPath = [self.tableView indexPathForCell:sender];
	NSURL *theURL = [self.morsels objectAtIndex:theIndexPath.row];


	CMorselViewController *theViewController = NULL;
	if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
		theViewController = AssertCast_(CMorselViewController, [(UINavigationController *)(segue.destinationViewController) topViewController]);
		}
	else
		{
		theViewController = AssertCast_(CMorselViewController, segue.destinationViewController);
		}


	theViewController.URL = theURL; // UIStoryboardReplaceSegue
	}

- (IBAction)flip:(id)sender
	{
	[self dismissViewControllerAnimated:YES completion:NULL];
	}

@end
