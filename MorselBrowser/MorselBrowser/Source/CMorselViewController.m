//
//  CViewController.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CMorselViewController.h"

#import "CMorsel.h"
#import "CMorselClient.h"

@interface CMorselViewController ()
@property (readwrite, nonatomic, strong) CMorselClient *morselClient;
@property (readwrite, nonatomic, strong) CMorsel *morsel;
@property (readwrite, nonatomic, strong) UIView *morselRootView;
@end

@implementation CMorselViewController

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
		self.morselClient = [[CMorselClient alloc] init];
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

//		[self.view removeConstraints:self.view.constraints];

//		[self.morselRootView removeFromSuperview];

		self.morselRootView = _morsel.rootObject;
		if (self.morselRootView != NULL)
			{
			[self.view addSubview:self.morselRootView];
			[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.morselRootView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
			[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.morselRootView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
			}
		}
	}

- (IBAction)reload:(id)sender
	{
	}

@end
