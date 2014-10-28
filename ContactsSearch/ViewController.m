//
//  ViewController.m
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@end


@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    ContactsSearchDisplayController *vc = [ContactsSearchDisplayController csdc];
    vc.csDelegate = self;
    [self addChildViewController: vc];
    vc.view.frame = self.contentView.bounds;
    [self.contentView addSubview: vc.view];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [super didReceiveMemoryWarning];
}


#pragma mark - ContactSearchDelegate

- (void) contactSelected: (ABRecordRef) contact
{
    NSString *display = [ContactsSearchDisplayController displayStringForContact: contact];

    NSLog(@"%s %@", __PRETTY_FUNCTION__, display);
}


@end
