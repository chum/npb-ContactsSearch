//
//  ContactsSearchBarViewController.m
//  ContactsSearch
//
//  Created by Olie on 10/28/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ContactsSearchDisplayController.h"



@interface ContactsSearchDisplayController ()
@property(strong, nonatomic) NSMutableArray *allContacts;
@property(strong, nonatomic) NSString *previousSearchText;
@property(strong, nonatomic) NSMutableArray *tableItems;
@end



@implementation ContactsSearchDisplayController

#pragma mark - Lifecycle

+ (ContactsSearchDisplayController*) csdc
{
    ContactsSearchDisplayController *result = [[ContactsSearchDisplayController alloc] initWithNibName: nil bundle: nil];

    return result;
}


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self)
    {
        _allContacts = [NSMutableArray new];
        _tableItems  = [NSMutableArray new];
        _previousSearchText = @"";
    }

    return self;
}



- (void) viewDidLoad
{
    [super viewDidLoad];

    [self updateContacts];
}


- (void) didReceiveMemoryWarning
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [super didReceiveMemoryWarning];
}


#pragma mark - Support

-(BOOL) addressBookAccessStatus: (ABAddressBookRef) addressBook
{
    __block BOOL accessGranted = NO;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return accessGranted;
}


+ (BOOL) phoneNumberIsValid: (NSString*) phoneNumber
{
    //* FIXME: Use Sani's library routines to actually validate the phone #
    //      Current code counts any non-nil phone# as valid

    return ([phoneNumber length] > 0);
}


- (void) updateContacts
{
    [_allContacts removeAllObjects];

    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions (NULL, &error);
    if (error != nil)
    {
        NSLog(@"%s ***** ERROR: %@", __PRETTY_FUNCTION__, error);
    }

    BOOL accessGranted = [self addressBookAccessStatus: addressBook];

    if (accessGranted)
    {
        NSArray *myContacts = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople (addressBook);

        NSLog(@"%s [DEBUG] %ld contacts", __PRETTY_FUNCTION__, (unsigned long)[myContacts count]);

        //* FIXME: If we want to do any sorting, do it here.

        [_allContacts addObjectsFromArray: myContacts];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle: @"No access"
                                    message: @"Address book access has not been granted"
                                   delegate: nil
                          cancelButtonTitle: @"Ok"
                          otherButtonTitles: nil]
         show];
    }
}


- (void) updateTableItems
{
    NSArray *contacts = ([self.searchbar.text hasPrefix: _previousSearchText])
                        ? [_tableItems copy]
                        : [_allContacts copy];

   [_tableItems removeAllObjects];
       
    int count = (int)[contacts count];
    for (int index = 0 ; index < count ; ++index)
    {
        ABRecordRef contact = (__bridge ABRecordRef) ([contacts objectAtIndex: index]);
        NSString *display = [ContactsSearchDisplayController displayStringForContact: contact];

        //* FIXME: do correct filtering, as desired
        NSString *matchString = self.searchbar.text;
        if ([display rangeOfString: matchString].location != NSNotFound)
        {
            [_tableItems addObject: (__bridge id)(contact)];
        }
    }
}


#pragma mark - UITableViewDataSource

+ (NSString*) displayStringForContact: (ABRecordRef) contact
{
    NSString *displayString = @"- no contact name -";

    // get contact info
    NSString *firstName = (__bridge NSString*) (ABRecordCopyValue(contact, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge NSString*) (ABRecordCopyValue(contact, kABPersonLastNameProperty));

    if (lastName == nil)
    {
        if (firstName != nil)
        {
            displayString = firstName;
        }
    }
    else if (firstName == nil)
    {
        if (lastName != nil)
        {
            displayString = lastName;
        }
    }
    else
    {
        displayString = [NSString stringWithFormat: @"%@, %@", lastName, firstName];
    }

    NSString *phoneNumber = [self phoneNumberForContact: contact];
    if (phoneNumber != nil)
    {
        displayString = [displayString stringByAppendingFormat: @" : %@", phoneNumber];
    }

    return displayString;
}


+ (NSString*) phoneNumberForContact: (ABRecordRef) contact
{
    NSString *result = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);

    if (ABMultiValueGetCount(phoneNumbers) > 0)
    {
        result = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }

    return result;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_tableItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString * const tableID = @"ContactsSearchDisplayController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: tableID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // get contact
    int row = (int) [indexPath row];
    ABRecordRef contact = (__bridge ABRecordRef) ([_tableItems objectAtIndex: row]);
    cell.textLabel.text = [ContactsSearchDisplayController displayStringForContact: contact];

    return cell;
}


#pragma mark - UITableViewDelegate

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    int row = (int) [indexPath row];
    ABRecordRef contact = (__bridge ABRecordRef) ([_tableItems objectAtIndex: row]);

    [_csDelegate contactSelected: contact];
}


#pragma mark - UISearchBarDelegate

- (void) searchBar: (UISearchBar*) searchBar textDidChange: (NSString*) searchText; // called when text changes (including clear)
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [self updateTableItems];
}


- (void) searchBarBookmarkButtonClicked: (UISearchBar*) searchBar;              // called when bookmark button pressed
{
}


- (void) searchBarCancelButtonClicked: (UISearchBar*) searchBar;                // called when cancel button pressed
{
}


- (void) searchBarResultsListButtonClicked: (UISearchBar*) searchBar;           // called when search results button pressed
{
}


#pragma mark - UISearchResultsUpdating

// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
- (void) updateSearchResultsForSearchController: (UISearchController*) searchController;
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [self updateTableItems];
}

@end
