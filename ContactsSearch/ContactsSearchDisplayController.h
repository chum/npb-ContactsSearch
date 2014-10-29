//
//  ContactsSearchBarViewController.h
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>


@protocol ContactSearchDelegate <NSObject>
- (void) contactSelected: (ABRecordRef) contact;
@end


@interface ContactsSearchDisplayController : UIViewController
    <UISearchBarDelegate, UISearchControllerDelegate,
    UISearchDisplayDelegate, UISearchResultsUpdating,
    UITableViewDataSource, UITableViewDelegate>

+ (ContactsSearchDisplayController*) csdc;

+ (NSString*) displayStringForContact: (ABRecordRef) contact;
+ (NSString*) fullDisplayStringForContact: (ABRecordRef) contact;
+ (NSString*) phoneNumberForContact: (ABRecordRef) contact;
+ (BOOL) phoneNumberIsValid: (NSString*) phoneNumber;

@property(weak, nonatomic) id<ContactSearchDelegate> csDelegate;

@property(weak, nonatomic) IBOutlet UISearchBar *searchbar;
//@property(weak, nonatomic) IBOutlet UISearchController *searchDisplayController;
@end
