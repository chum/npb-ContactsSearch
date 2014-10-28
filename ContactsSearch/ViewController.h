//
//  ViewController.h
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactsSearchDisplayController.h"


@interface ViewController : UIViewController
    <ContactSearchDelegate>

@property(weak, nonatomic) IBOutlet UIView *contentView;
@end

