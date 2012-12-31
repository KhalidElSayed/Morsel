//
//  CBonjourBrowserViewController.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/11/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CBonjourBrowserViewController.h"

#import "CMorselViewController.h"

@interface CBonjourBrowserViewController () <NSNetServiceBrowserDelegate, UIAlertViewDelegate>
@property (readwrite, nonatomic, strong) NSNetServiceBrowser *serviceBrowser;
@property (readwrite, nonatomic, strong) NSMutableArray *domains;
@property (readwrite, nonatomic, strong) NSMutableDictionary *servicesByDomain;
@end

#pragma mark -

@implementation CBonjourBrowserViewController

- (void)viewWillAppear:(BOOL)animated
	{
    [super viewWillAppear:animated];

	self.domains = [NSMutableArray array];
	self.servicesByDomain = [NSMutableDictionary dictionary];

	self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
	self.serviceBrowser.delegate = self;
	[self.serviceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@""];
	}

- (void)viewWillDisappear:(BOOL)animated
	{
    [super viewWillDisappear:animated];

	[self.serviceBrowser stop];
	self.serviceBrowser = NULL;
	}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
	{
    return([self.domains count]);
	}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
	NSString *theDomain = self.domains[section];


    return([self.servicesByDomain[theDomain] count]);
	}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
	{
	return(self.domains[section]);
	}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	NSString *theDomain = self.domains[indexPath.section];
	NSNetService *theService = self.servicesByDomain[theDomain][indexPath.row];

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	cell.textLabel.text = theService.name;

    // Configure the cell...
    
    return cell;
	}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
	{
	if ([sender isKindOfClass:[NSURL class]])
		{
		CMorselViewController *theViewController = segue.destinationViewController;
		theViewController.URL = sender;
		}
	else if ([sender isKindOfClass:[UITableViewCell class]])
		{
		NSIndexPath *theIndexPath = [self.tableView indexPathForCell:sender];
		NSString *theDomain = self.domains[theIndexPath.section];
		NSNetService *theService = self.servicesByDomain[theDomain][theIndexPath.row];
		if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
			{
			CMorselViewController *theViewController = ((UINavigationController *)(segue.destinationViewController)).topViewController;
			theViewController.service = theService;
			}
		}
	}

#pragma mark -

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
	{
	if ([self.servicesByDomain[aNetService.domain] containsObject:aNetService] == NO)
		{
		if ([self.domains containsObject:aNetService.domain] == NO)
			{
			[self.domains addObject:aNetService.domain];
			self.servicesByDomain[aNetService.domain] = [NSMutableArray array];
			}
		[self.servicesByDomain[aNetService.domain] addObject:aNetService];

		[self.tableView reloadData];
		}
	}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
	{
	if ([self.servicesByDomain[aNetService.domain] containsObject:aNetService] == YES)
		{
		[self.servicesByDomain[aNetService.domain] removeObject:aNetService];
		if ([self.servicesByDomain[aNetService.domain] count] == 0)
			{
			[self.servicesByDomain removeObjectForKey:aNetService.domain];
			[self.domains removeObject:aNetService.domain];
			}

		[self.tableView reloadData];
		}
	}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
	{
	NSLog(@"%d", buttonIndex);
	if (buttonIndex == 1)
		{
		NSString *theURLString = ((UITextField *)[alertView textFieldAtIndex:0]).text;
		NSURL *theURL = [NSURL URLWithString:theURLString];

		[self performSegueWithIdentifier:@"PUSH" sender:theURL];
		}
	}

- (IBAction)more:(id)sender
	{
	UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:@"URL" message:NULL delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", NULL];
	theAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[theAlertView show];
	}


@end
