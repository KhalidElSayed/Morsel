//
//  CTestLoginViewController.m
//  MorselBrowser
//
//  Created by Jonathan Wight on 12/14/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CTestLoginViewController.h"

#import "CMorsel.h"

@interface CTestLoginViewController () <UIAlertViewDelegate>
@property (readwrite, nonatomic, weak) IBOutlet UITextField *nameField;
@end

@implementation CTestLoginViewController

- (void)loadView
	{
	CMorsel *theMorsel = [[CMorsel alloc] initWithName:@"_test" error:NULL];
	NSArray *theObjects = [theMorsel instantiateWithOwner:self options:NULL];
	self.view = [theObjects objectAtIndex:0];
	NSLog(@"%@", self.view);
	NSLog(@"%@", self.nameField);
	}

- (IBAction)ok:(id)sender
	{
	NSLog(@"OK:");
	NSString *theMessage = [NSString stringWithFormat:@"Hello %@", self.nameField.text];
	UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NULL message:theMessage delegate:self cancelButtonTitle:NULL otherButtonTitles:@"OK", NULL];
	[theAlert show];
	}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
	{
	[self dismissViewControllerAnimated:YES completion:NULL];
	}
//- (IBAction)ok
//	{
//	NSLog(@"OK");
//	}

@end
