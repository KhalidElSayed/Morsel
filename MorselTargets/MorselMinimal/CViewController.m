//
//  CViewController.m
//  MorselMinimal
//
//  Created by Jonathan Wight on 1/2/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CViewController.h"

#import "CMorsel.h"
#import "UIView+Debugging.h"

@interface CViewController ()
@property (readwrite, nonatomic, weak) UILabel *nameField;
@end

#pragma mark -

@implementation CViewController

- (id)init
    {
    if ((self = [self initWithNibName:NULL bundle:NULL]) != NULL)
        {
        }
    return self;
    }

- (void)loadView
    {
    NSError *theError = NULL;
    CMorsel *theMorsel = [[CMorsel alloc] initWithName:NSStringFromClass([self class]) bundle:NULL error:&theError];
    [theMorsel instantiateWithOwner:self options:NULL error:&theError];
    }

- (IBAction)ok:(id)sender
    {
    NSLog(@"OK!: %@", self.nameField.text);
    }

@end
