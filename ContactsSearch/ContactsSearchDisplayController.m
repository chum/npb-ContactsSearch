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

#define USE_UNIFIED_CONTACTS            1


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


- (ABRecordRef) contactInArray: (NSArray*) array atIndex: (int) index
{
#if USE_UNIFIED_CONTACTS
    NSSet *contactSet = [array objectAtIndex: index];
    ABRecordRef contact = (__bridge ABRecordRef) ([contactSet anyObject]);

#else

    ABRecordRef contact = (__bridge ABRecordRef) [array objectAtIndex: index];

#endif

    return contact;
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

#if USE_UNIFIED_CONTACTS   // New way
        // See: http://stackoverflow.com/questions/11351454/dealing-with-duplicate-contacts-due-to-linked-cards-in-ios-address-book-api
        NSLog(@"%s (new way)", __PRETTY_FUNCTION__);

        NSMutableSet *unifiedRecordsSet = [NSMutableSet set];

        // Iterate all ABRecords
        CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
        int recordCount = (int) CFArrayGetCount(records);
        for (CFIndex index = 0 ; index < recordCount ; ++index)
        {
            ABRecordRef record = CFArrayGetValueAtIndex(records, index);

            // For each contact, create a set with all of the linked contacts
            NSMutableSet *contactSet = [NSMutableSet set];
            [contactSet addObject: (__bridge id) record];

            NSArray *linkedRecordsArray = (__bridge NSArray*) ABPersonCopyArrayOfAllLinkedPeople(record);
            [contactSet addObjectsFromArray: linkedRecordsArray];

            // Add this set of contacts to our master set (weeding-out duplicates)
            NSSet *unifiedRecord = [[NSSet alloc] initWithSet: contactSet];
            [unifiedRecordsSet addObject: unifiedRecord];

            CFRelease(record);
        }
        
        CFRelease(records);
        CFRelease(addressBook);

        for (NSSet *contactSet in unifiedRecordsSet)
        {
            [_allContacts addObject: contactSet];
            int setCount = (int) [contactSet count];
            if (setCount > 1)
            {
                NSLog(@"%s Linked contacts:", __PRETTY_FUNCTION__);
                NSArray *tmpArray = [contactSet allObjects];
                for (int index = 0 ; index < setCount ; ++index)
                {
                    ABRecordRef oneContact = (__bridge ABRecordRef)[tmpArray objectAtIndex: index];
                    NSLog(@"%s .. %@", __PRETTY_FUNCTION__, [ContactsSearchDisplayController displayStringForContact: oneContact]);
                }
            }
        }

        NSLog(@"%s contacts: %d", __PRETTY_FUNCTION__, (int) [_allContacts count]);
    
#else   // Old way
        NSArray *myContacts = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople (addressBook);

        NSLog(@"%s [DEBUG] %ld contacts", __PRETTY_FUNCTION__, (unsigned long)[myContacts count]);

        //* FIXME: If we want to do any sorting, do it here.

        [_allContacts addObjectsFromArray: myContacts];

#endif
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
    BOOL keepGoing = ([self.searchbar.text hasPrefix: _previousSearchText]);
    NSArray *contacts = (keepGoing
                         ? [_tableItems copy]
                         : [_allContacts copy] );

   [_tableItems removeAllObjects];
       
    int count = (int)[contacts count];
    NSString *matchString = [self.searchbar.text lowercaseString];
    for (int index = 0 ; index < count ; ++index)
    {
        NSSet *contactSet = [contacts objectAtIndex: index];
        ABRecordRef contact = [self contactInArray: contacts atIndex: index];
        NSString *display = [[ContactsSearchDisplayController displayStringForContact: contact] lowercaseString];

        //* FIXME: do correct filtering, as desired
        if ([display rangeOfString: matchString].location != NSNotFound)
        {
            [_tableItems addObject: contactSet];
        }
    }
}


#pragma mark - UITableViewDataSource

+ (NSString*) fullDisplayStringForContact: (ABRecordRef) contact
{
    // get contact info
    NSString *firstName = (__bridge NSString*) (ABRecordCopyValue(contact, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge NSString*) (ABRecordCopyValue(contact, kABPersonLastNameProperty));

    NSString *result = [NSString stringWithFormat: @"FirstName: %@\nLastName: %@\nPhone numbers: [\n", firstName, lastName];

    ABMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
    int phoneCount = (int) ABMultiValueGetCount(phoneNumbers);

    for (int index = 0 ; index < phoneCount ; ++index)
    {
        NSString *onePhone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, index);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, index);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        result = [result stringByAppendingFormat: @"  {Type: %@, Number: %@}\n", phoneLabel, onePhone];
    }

    result = [result stringByAppendingString: @"]"];

    return result;
}


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
    ABRecordRef contact = [self contactInArray: _tableItems atIndex: row];
    cell.textLabel.text = [ContactsSearchDisplayController displayStringForContact: contact];

    return cell;
}


#pragma mark - UITableViewDelegate

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    int row = (int) [indexPath row];
    ABRecordRef contact = [self contactInArray: _tableItems atIndex: row];

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


#pragma mark - DEBUG

- (void) debugJillTest
{
    NSLog(@"%s ====================================================", __PRETTY_FUNCTION__);

    int allContactsCount = (int) [_allContacts count];
    NSLog(@"There are %d entries in your contacts list.", allContactsCount);

    // check all contact-sets
    for (int ii = 0 ; ii < allContactsCount ; ++ii)
    {
#if USE_UNIFIED_CONTACTS
        NSSet *oneContactSet = [_allContacts objectAtIndex: ii];

        // check each contact within a set
        NSArray *contacts = [oneContactSet allObjects];
        int contactCount = (int) [contacts count];
        for (int index = 0 ; index < contactCount ; ++index)
        {
            ABRecordRef oneContact = (__bridge ABRecordRef) [contacts objectAtIndex: index];

#else
            ABRecordRef oneContact = (__bridge ABRecordRef) [_allContacts objectAtIndex: ii];

#endif
            // Look for Jill
            NSString *displayString = [ContactsSearchDisplayController displayStringForContact: oneContact];
            NSRange found = [[displayString lowercaseString] rangeOfString: @"jill"];
            if (found.location != NSNotFound)
            {

#if USE_UNIFIED_CONTACTS
                // We found Jill!
                NSLog(@"Item #%d contains %d contacts (> 1 indicates 'linked' contacts", ii, contactCount);
                for (int ind2 = 0 ; ind2 < contactCount ; ++ind2)
                {
                    ABRecordRef jill = (__bridge ABRecordRef) [contacts objectAtIndex: index];
                    NSString *fullString = [ContactsSearchDisplayController fullDisplayStringForContact: jill];
                    NSLog (@" .. Item %d-%d is contact:\n%@", ii, ind2, fullString);
                    NSLog (@"");
                }
#else
                NSString *fullString = [ContactsSearchDisplayController fullDisplayStringForContact: oneContact];
                NSLog(@"Item #%d is:\n%@", ii, fullString);

#endif
                NSLog(@"==========\n");
            }
#if USE_UNIFIED_CONTACTS
        }
#endif
    }

    NSLog(@"%s .. end.\n\n\n", __PRETTY_FUNCTION__);
}


@end
