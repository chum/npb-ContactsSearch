//
//  ViewController.m
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ViewController.h"


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


#pragma mark - ContactSearchDelegate

- (void) contactSelected: (ABRecordRef) contact
{
    NSString *info = [ContactsSearchDisplayController fullDisplayStringForContact: contact];
    [[[UIAlertView alloc] initWithTitle: @"Contact"
                                message: info
                               delegate: nil
                      cancelButtonTitle: @"Ok"
                      otherButtonTitles: nil]
     show];

    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}


@end
