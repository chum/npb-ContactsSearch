//
//  ViewController.m
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ViewController.h"

//#import <AddressBook/AddressBook.h>
//#import <AddressBookUI/AddressBookUI.h>

@interface ViewController ()
//@property(strong, nonatomic) NSMutableArray *tableItems;
@end


@implementation ViewController

//#pragma mark - Lifecycle
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//
//    _tableItems = [NSMutableArray new];
//}
//
//
//- (void) viewDidAppear: (BOOL) animated
//{
//    [super viewDidAppear: animated];
//
//    if ([_tableItems count] == 0)
//    {
//        [self updateContacts];
//    }
//}
//
//
//- (void)didReceiveMemoryWarning
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//
//    [super didReceiveMemoryWarning];
//}
//
//
//#pragma mark - Support
//
//-(BOOL) addressBookAccessStatus: (ABAddressBookRef) addressBook
//{
//    __block BOOL accessGranted = NO;
//
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
//        accessGranted = granted;
//        dispatch_semaphore_signal(sema);
//    });
//
//    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//
//    return accessGranted;
//}
//
//
//- (void) updateContacts
//{
//    [_tableItems removeAllObjects];
//
//    CFErrorRef error = nil;
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions (NULL, &error);
//    if (error != nil)
//    {
//        NSLog(@"%s ***** ERROR: %@", __PRETTY_FUNCTION__, error);
//    }
//
//    BOOL accessGranted = [self addressBookAccessStatus: addressBook];
//
//    if (accessGranted)
//    {
//        NSArray *allContacts = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople (addressBook);
//
//        NSLog(@"%s [DEBUG] %lu contacts", __PRETTY_FUNCTION__,(unsigned long) (unsigned long) [allContacts count]);
//
//        // If we want to do any sorting, do it here.
//
//        [_tableItems addObjectsFromArray: allContacts];
//    }
//    else
//    {
//        [[[UIAlertView alloc] initWithTitle: @"No access"
//                                    message: @"Address book access has not been granted"
//                                   delegate: nil
//                          cancelButtonTitle: @"Ok"
//                          otherButtonTitles: nil]
//         show];
//    }
//}
//
//
//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
//{
//    return [_tableItems count];
//}
//
//
//// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
//// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//{
//    NSString * const tableID = @"searchCellID";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableID];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: tableID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//
//    // get contact
//    int row = (int) [indexPath row];
//    ABRecordRef contact = (__bridge ABRecordRef) ([_tableItems objectAtIndex: row]);
//
//    // get contact info
//    NSString *firstName = (__bridge NSString*) (ABRecordCopyValue(contact, kABPersonFirstNameProperty));
//    NSString *lastName  = (__bridge NSString*) (ABRecordCopyValue(contact, kABPersonLastNameProperty));
//    NSString *displayString = [NSString stringWithFormat: @"%@, %@", lastName, firstName];
//
//    ABMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
//
//    if (ABMultiValueGetCount(phoneNumbers) > 0)
//    {
//        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
//        displayString = [displayString stringByAppendingFormat: @" : %@", phoneNumber];
//    }
//
//    cell.textLabel.text = displayString;
//
//    return cell;
//}
//
//
//#pragma mark - UITableViewDelegate
//
//
//#pragma mark - UISearchBarDelegate
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
//{
//}
//
//
//- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;                   // called when bookmark button pressed
//{
//}
//
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed
//{
//}
//
//
//- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2); // called when search results button pressed
//{
//}
//
//
//#pragma mark - UISearchResultsUpdating
//
//// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;
//{
//}


@end
