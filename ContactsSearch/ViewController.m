//
//  ViewController.m
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ViewController.h"

#import "ScoreParamsViewController.h"


@interface ViewController ()
@property(strong, nonatomic) ContactsSearchDisplayController *csdc;
@end


@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _csdc = [ContactsSearchDisplayController csdc];
    _csdc.csDelegate = self;
    [self addChildViewController: _csdc];
    _csdc.view.frame = self.contentView.bounds;
    [self.contentView addSubview: _csdc.view];
}


#pragma mark - ContactSearchDelegate

- (void) contactSelected: (ContactRecord*) contact
{
    NSString *info = [contact longDisplayString];
    [[[UIAlertView alloc] initWithTitle: @"Contact"
                                message: info
                               delegate: nil
                      cancelButtonTitle: @"Ok"
                      otherButtonTitles: nil]
     show];

    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}


#pragma mark - Actions

- (IBAction) debugAdjustSort: (id) sender
{
    ScoreParamsViewController *vc = [[ScoreParamsViewController alloc] initWithNibName: nil bundle: nil];
    [self presentViewController: vc animated: YES completion: nil];
}


- (IBAction) debugJillTest: (id) sender
{
    [_csdc debugJillTest];
}


@end
