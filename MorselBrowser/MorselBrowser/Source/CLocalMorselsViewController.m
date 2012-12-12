//
//  CLocalMorselsViewController.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/12/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CLocalMorselsViewController.h"

#import "CMorselViewController.h"

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
	CMorselViewController *theViewController =segue.destinationViewController;
	theViewController.URL = theURL;
	}

- (IBAction)flip:(id)sender
	{
	[self dismissViewControllerAnimated:YES completion:NULL];
	}

@end
