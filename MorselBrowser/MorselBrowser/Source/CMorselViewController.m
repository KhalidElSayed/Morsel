//
//  CViewController.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorselViewController.h"

#import "CMorsel.h"
#import "CRemoteMorselClient.h"
#import "CResizerThumb.h"
#import "UIView+ConstraintConveniences.h"

@interface CMorselViewController () <UISplitViewControllerDelegate>
@property (readwrite, nonatomic, strong) CRemoteMorselClient *morselClient;
@property (readwrite, nonatomic, strong) CMorsel *morsel;
@property (readwrite, nonatomic, strong) UIView *morselRootView;
@property (readwrite, nonatomic, strong) UIPopoverController *masterPopoverController;
@end

#pragma mark -

@implementation CMorselViewController

- (void)awakeFromNib
	{
	[super awakeFromNib];

	if (self.splitViewController)
		{
		self.splitViewController.delegate = self;
		}
	}

- (void)viewDidLoad
	{
    [super viewDidLoad];


	if (self.URL.isFileURL == YES)
		{
		NSError *theError = NULL;
		CMorsel *theMorsel = [[CMorsel alloc] initWithURL:self.URL error:&theError];
		self.morsel = theMorsel;
		}
	else
		{
		self.morselClient = [[CRemoteMorselClient alloc] init];
		self.morselClient.URL = self.URL;
		self.morselClient.service = self.service;

		__weak typeof(self) weakSelf = self;

		self.morselClient.morselHandler = ^(CMorsel *morsel, NSError *error) {
			weakSelf.morsel = morsel;
			};
		[self.morselClient start];
		}
	}

- (void)setMorsel:(CMorsel *)morsel
	{
	if (_morsel != morsel)
		{
		_morsel = morsel;

		[self.view removeConstraints:self.view.constraints];
		[self.morselRootView removeFromSuperview];

		self.morselRootView = [_morsel instantiateWithOwner:NULL options:NULL][0];
		if (self.morselRootView != NULL)
			{
			[self.view addSubview:self.morselRootView];
			[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.morselRootView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
			[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.morselRootView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
			}
		}

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
		CResizerThumb *theThumb = [[CResizerThumb alloc] initWithFrame:CGRectZero];
		theThumb.translatesAutoresizingMaskIntoConstraints = NO;
		[self.morselRootView addSubview:theThumb];
		theThumb.widthConstraint = [self.morselRootView constantWidthConstraint];
		theThumb.heightConstraint = [self.morselRootView constantHeightConstraint];
		NSDictionary *theViews = @{ @"thumb": theThumb };
		[theThumb.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[thumb(16)]-0-|" options:0 metrics:NULL views:theViews]];
		[theThumb.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[thumb(16)]-0-|" options:0 metrics:NULL views:theViews]];
		}
	}

- (IBAction)reload:(id)sender
	{
	}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
	{
	NSLog(@"WILL HIDE");

    barButtonItem.title = @"Morsels";
    self.masterPopoverController = pc;

	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button
	{
	NSLog(@"WILL SHOW: %@", button);

    self.masterPopoverController = NULL;

	[self.navigationItem setLeftBarButtonItem:NULL animated:YES];
	}

@end
