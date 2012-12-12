//
//  CViewController.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/5/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMorselViewController : UIViewController

@property (readwrite, nonatomic, strong) NSURL *URL;
@property (readwrite, nonatomic, strong) NSNetService *service;

@end
