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
    [self updateTableItems];
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


- (ContactRecord*) contactInArray: (NSArray*) array atIndex: (int) index
{
#if USE_UNIFIED_CONTACTS
    NSSet *contactSet = [array objectAtIndex: index];
    ContactRecord *contact = [self contactFromUnifiedSet: contactSet];

#else
    ContactRecord *contact = [array objectAtIndex: index];

#endif

    return contact;
}


#if USE_UNIFIED_CONTACTS
- (ContactRecord*) contactFromUnifiedSet: (NSSet*) contactSet
{
    ContactRecord *result = [contactSet anyObject];

    return result;
}

#endif


+ (BOOL) phoneNumberIsValid: (NSString*) phoneNumber
{
    //* FIXME: Use Sani's library routines to actually validate the phone #
    //      Current code counts any non-nil phone# as valid

    return ([phoneNumber length] > 0);
}


- (NSArray*) sortContacts: (NSArray*) contacts
{
    NSArray *result = [contacts sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
#if USE_UNIFIED_CONTACTS
        NSSet *s1 = obj1;
        NSSet *s2 = obj2;

        ContactRecord *c1 = [self contactFromUnifiedSet: s1];
        ContactRecord *c2 = [self contactFromUnifiedSet: s2];

#else
        ContactRecord *c1 = obj1;
        ContactRecord *c2 = obj2;
#endif
        NSComparisonResult scoreCompare = [@(-c1.score) compare: @(-c2.score)]; // negative to reverse the sort (highest on top)

        if (scoreCompare == NSOrderedSame)
        {
            NSString *d1 = [c1 displayString];
            NSString *d2 = [c2 displayString];

            return [d1 compare: d2];
        }

        return scoreCompare;
    }];

    return result;
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
        //NSLog(@"%s (new way)", __PRETTY_FUNCTION__);

        NSMutableSet *unifiedRecordsSet = [NSMutableSet set];

        // Iterate all ABRecords
        CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
        int recordCount = (int) CFArrayGetCount(records);
        for (CFIndex index = 0 ; index < recordCount ; ++index)
        {
            ABRecordRef abRecord = CFArrayGetValueAtIndex(records, index);
            ContactRecord *contactRecord = [ContactRecord contactWithABRecord: abRecord];

            // For each contact, create a set with all of the linked contacts
            NSMutableSet *contactSet = [NSMutableSet set];
            [contactSet addObject: contactRecord];

            NSArray *linkedRecordsArray = (__bridge NSArray*) ABPersonCopyArrayOfAllLinkedPeople(abRecord);
            int linkCount = (int) [linkedRecordsArray count];
            for (int link = 0 ; link < linkCount ; ++link)
            {
                ABRecordRef abLink = (__bridge ABRecordRef) [linkedRecordsArray objectAtIndex: link];
                ContactRecord *contactLink = [ContactRecord contactWithABRecord: abLink];
                [contactSet addObject: contactLink];
            }

            // Add this set of contacts to our master set (weeding-out duplicates)
            NSSet *unifiedRecord = [[NSSet alloc] initWithSet: contactSet];
            [unifiedRecordsSet addObject: unifiedRecord];
        }
        
        CFRelease(records);
        CFRelease(addressBook);

        for (NSSet *contactSet in unifiedRecordsSet)
        {
            [_allContacts addObject: contactSet];

// Debug logging
//            int setCount = (int) [contactSet count];
//            if (setCount > 1)
//            {
//                //NSLog(@"%s Linked contacts:", __PRETTY_FUNCTION__);
//                NSArray *tmpArray = [contactSet allObjects];
//                for (int index = 0 ; index < setCount ; ++index)
//                {
//                    ContactRecord *contact = [tmpArray objectAtIndex: index];
//                    NSLog(@"%s .. %@", __PRETTY_FUNCTION__, [contact displayString]);
//                }
//            }
        }

        NSLog(@"%s contacts: %d", __PRETTY_FUNCTION__, (int) [_allContacts count]);
    
#else   // Old way
        NSArray *myContacts = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople (addressBook);

        NSLog(@"%s [DEBUG] %ld contacts", __PRETTY_FUNCTION__, (unsigned long)[myContacts count]);

        [_allContacts addObjectsFromArray: myContacts];

#endif

        _allContacts = [[self sortContacts: _allContacts] mutableCopy];
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
    BOOL keepGoing =   (_previousSearchText.length > 0)
                    && ([self.searchbar.text hasPrefix: _previousSearchText]);

    NSArray *contacts = (keepGoing
                         ? [_tableItems copy]
                         : [_allContacts copy] );

   [_tableItems removeAllObjects];
       
    int count = (int)[contacts count];
    NSString *matchString = [self.searchbar.text lowercaseString];
    for (int index = 0 ; index < count ; ++index)
    {
        NSSet *contactSet = [contacts objectAtIndex: index];
        ContactRecord *contact = [self contactInArray: contacts atIndex: index];
        NSString *display = [[contact displayString] lowercaseString];

        if (([matchString length] == 0)
        ||  ([display rangeOfString: matchString].location != NSNotFound) )
        {
            [_tableItems addObject: contactSet];
        }
    }
}


#pragma mark - UITableViewDataSource

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
    ContactRecord *contact = [self contactInArray: _tableItems atIndex: row];

//    if (contact.score == 0)
//    {
//        cell.textLabel.text = [contact displayString];
//    }
//    else
    {
        cell.textLabel.text = [NSString stringWithFormat: @"[%d]  %@", contact.score, [contact displayString]];
    }

    return cell;
}


#pragma mark - UITableViewDelegate

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    int row = (int) [indexPath row];
    ContactRecord *contact = [self contactInArray: _tableItems atIndex: row];

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
            ContactRecord *oneContact = [contacts objectAtIndex: index];

#else
            ContactRecord *oneContact = [_allContacts objectAtIndex: ii];

#endif
            // Look for Jill
            NSString *displayString = [oneContact displayString];
            NSRange found = [[displayString lowercaseString] rangeOfString: @"jill"];
            if (found.location != NSNotFound)
            {

#if USE_UNIFIED_CONTACTS
                // We found Jill!
                NSLog(@"Item #%d contains %d contacts (> 1 indicates 'linked' contacts", ii, contactCount);
                for (int ind2 = 0 ; ind2 < contactCount ; ++ind2)
                {
                    ContactRecord *jill = [contacts objectAtIndex: index];
                    NSString *fullString = [jill longDisplayString];
                    NSLog (@" .. Item %d-%d is contact:\n%@", ii, ind2, fullString);
                    NSLog (@"");
                }
#else
                NSString *fullString = [oneContact longDisplayString];
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
