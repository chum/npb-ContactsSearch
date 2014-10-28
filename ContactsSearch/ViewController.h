//
//  ViewController.h
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 ManyFriends.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
    <UISearchBarDelegate, UISearchControllerDelegate,
    UISearchDisplayDelegate, UISearchResultsUpdating,
    UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property(weak, nonatomic) IBOutlet UISearchController *searchController;

@end

