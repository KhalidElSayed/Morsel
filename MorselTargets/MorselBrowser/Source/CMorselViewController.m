//
//	CViewController.m
//	Morsel
//
//	Created by Jonathan Wight on 12/5/12.
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

#import "CMorselViewController.h"

#import "CMorsel.h"
#import "CRemoteMorselClient.h"
#import "CResizerThumb.h"
#import "UIView+MorselExtensions.h"

@interface CMorselViewController () <UISplitViewControllerDelegate>
@property (readwrite, nonatomic, strong) CRemoteMorselClient *morselClient;
@property (readwrite, nonatomic, strong) CMorsel *morsel;
@property (readwrite, nonatomic, strong) UIView *morselRootView;
@property (readwrite, nonatomic, strong) UIPopoverController *masterPopoverController;
@end

#pragma mark -

@implementation CMorselViewController

//- (void)awakeFromNib
//	{
//	[super awakeFromNib];
//
//	if (self.splitViewController)
//		{
//		self.splitViewController.delegate = self;
//		}
//	}

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

		__weak typeof(self) weak_self = self;

		self.morselClient.morselHandler = ^(CMorsel *morsel, NSError *error) {
            __strong typeof(weak_self) strong_self = weak_self;
			strong_self.morsel = morsel;
			};
		[self.morselClient start];
		}
	}

- (void)setMorsel:(CMorsel *)morsel
	{
	if (_morsel != morsel)
		{
		_morsel = morsel;

		[self.view removeConstraints:[self.view recursiveConstraintsMatchingPredicate:[NSPredicate predicateWithFormat:@"firstItem == %@ OR secondItem == %@", self.morselRootView, self.morselRootView]]];
		[self.morselRootView removeFromSuperview];

		self.morselRootView = [_morsel instantiateWithOwner:NULL options:NULL error:NULL][@"root"];
		if (self.morselRootView != NULL)
			{
			[self.view addSubview:self.morselRootView];
			[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.morselRootView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
			[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.morselRootView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
			}
		}

//	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
//		{
//		CResizerThumb *theThumb = [[CResizerThumb alloc] initWithFrame:CGRectZero];
//		theThumb.translatesAutoresizingMaskIntoConstraints = NO;
//		[self.morselRootView addSubview:theThumb];
//		theThumb.widthConstraint = [self.morselRootView constantWidthConstraint];
//		theThumb.heightConstraint = [self.morselRootView constantHeightConstraint];
//		NSDictionary *theViews = @{ @"thumb": theThumb };
//		[theThumb.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[thumb(16)]-0-|" options:0 metrics:NULL views:theViews]];
//		[theThumb.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[thumb(16)]-0-|" options:0 metrics:NULL views:theViews]];
//		}
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
