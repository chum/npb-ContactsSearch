//
//  ContactsSearchBarViewController.h
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsSearchBarViewController : UISearchController
    <UISearchBarDelegate, UISearchControllerDelegate,
    UISearchDisplayDelegate, UISearchResultsUpdating,
    UITableViewDataSource, UITableViewDelegate>

@end
