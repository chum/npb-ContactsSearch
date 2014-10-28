//
//  ContactsSearchBarViewController.h
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsSearchDisplayController : UIViewController
    <UISearchBarDelegate, UISearchControllerDelegate,
    UISearchDisplayDelegate, UISearchResultsUpdating,
    UITableViewDataSource, UITableViewDelegate>

+ (ContactsSearchDisplayController*) csdc;

@property(weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property(weak, nonatomic) IBOutlet UISearchController *searchController;
@end
