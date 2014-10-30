//
//  ContactsSearchBarViewController.h
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>
#import "ContactRecord.h"


@protocol ContactSearchDelegate <NSObject>
- (void) contactSelected: (ContactRecord*) contact;
@end


@interface ContactsSearchDisplayController : UIViewController
    <UISearchBarDelegate, UISearchControllerDelegate,
    UISearchDisplayDelegate, UISearchResultsUpdating,
    UITableViewDataSource, UITableViewDelegate>

+ (ContactsSearchDisplayController*) csdc;

+ (BOOL) phoneNumberIsValid: (NSString*) phoneNumber;

- (void) debugJillTest;

@property(weak, nonatomic) id<ContactSearchDelegate> csDelegate;

@property(weak, nonatomic) IBOutlet UISearchBar *searchbar;
//@property(weak, nonatomic) IBOutlet UISearchController *searchDisplayController;
@end
