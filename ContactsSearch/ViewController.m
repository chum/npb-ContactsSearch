//
//  ViewController.m
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ViewController.h"

#import "ContactsSearchDisplayController.h"


@interface ViewController ()
@end


@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    ContactsSearchDisplayController *vc = [ContactsSearchDisplayController csdc];
    [self addChildViewController: vc];
    vc.view.frame = self.contentView.bounds;
    [self.contentView addSubview: vc.view];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [super didReceiveMemoryWarning];
}


@end
