//
//  ContactRecord.m
//  ContactsSearch
//
//  Created by Olie on 10/30/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ContactRecord.h"


@interface ContactRecord()
{
    ABRecordRef abContact;
}

@property(readwrite, nonatomic) int score;
@end



#pragma mark - DBFriendFinder specific

static NSInteger const IMAGE_SCORE = 20;
static NSInteger const NON_PERSON_PENALTY = 100;

// Lookup tables for properties and their score values.
// Single and multivalue properties are treated differently.
static NSArray *SINGLEVALUE_PROPERTIES = nil;
static NSArray *MULTIVALUE_PROPERTIES = nil;
static NSArray *MULTIBONUS_PROPERTIES = nil;

/**
 * A simple value object that stores an adress book contact property (an ABPropertyID)
 * and its associated importance score. We use this to construct a static lookup table
 * for determining the importance score of an address book contact.
 *
 * This is an internal class used by the DBFriendFinder class and should not be
 * exposed externally.
 */
@interface __DBPropertyScorePair : NSObject
@property(readonly, nonatomic) ABPropertyID property;
@property(readonly, nonatomic) NSInteger score;
- (instancetype) initWithProperty:(ABPropertyID)property score:(NSInteger)score;
+ (instancetype) pairWithProperty:(ABPropertyID)property score:(NSInteger)score;
@end

@implementation __DBPropertyScorePair

- (instancetype) initWithProperty:(ABPropertyID)property score:(NSInteger)score
{
    self = [super init];
    if (self)
    {
        _property = property;
        _score = score;
    }

    return self;
}


+ (instancetype) pairWithProperty:(ABPropertyID)property score:(NSInteger)score
{
    return [[__DBPropertyScorePair alloc] initWithProperty: property score: score];
}

@end


#pragma mark -

@implementation ContactRecord


#pragma mark - Lifecycle

+ (instancetype) contactWithABRecord: (ABRecordRef) abrecord
{
    [ContactRecord initialize];

    ContactRecord *result = [self new];
    result->abContact = abrecord;

    [result updateScore];

    return result;
}


+ (void) initialize
{
    if (SINGLEVALUE_PROPERTIES == nil)
    {
        SINGLEVALUE_PROPERTIES = @[
               // Contacts with nicknames and birthdays are likely to be more important.
               [__DBPropertyScorePair pairWithProperty: kABPersonNicknameProperty           score:  50],
               [__DBPropertyScorePair pairWithProperty: kABPersonBirthdayProperty           score: 150],
               [__DBPropertyScorePair pairWithProperty: kABPersonFirstNameProperty          score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonLastNameProperty           score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonMiddleNameProperty         score:  30],
               [__DBPropertyScorePair pairWithProperty: kABPersonPrefixProperty             score:  15],
               [__DBPropertyScorePair pairWithProperty: kABPersonSuffixProperty             score:  20],
               [__DBPropertyScorePair pairWithProperty: kABPersonFirstNamePhoneticProperty  score:  30],
               [__DBPropertyScorePair pairWithProperty: kABPersonMiddleNamePhoneticProperty score:  30],
               [__DBPropertyScorePair pairWithProperty: kABPersonOrganizationProperty       score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonJobTitleProperty           score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonDepartmentProperty         score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonPrefixProperty             score:  15],
               [__DBPropertyScorePair pairWithProperty: kABPersonNoteProperty               score:  40]
               ];
    }

    if (MULTIVALUE_PROPERTIES == nil)
    {
        MULTIVALUE_PROPERTIES = @[
              // Related names and associated dates (anniversaries) are likely to indicate
              // close relationships. Also, phone numbers and addresses rank higher than emails
              // and IM profiles.
              [__DBPropertyScorePair pairWithProperty: kABPersonRelatedNamesProperty   score: 200],
              [__DBPropertyScorePair pairWithProperty: kABPersonDateProperty           score: 250],
              [__DBPropertyScorePair pairWithProperty: kABPersonAddressProperty        score:  50],
              ];
    }

    if (MULTIBONUS_PROPERTIES == nil)
    {
        //NSLog(@"%s [DEBUG] kABPersonPhoneProperty: %d", __PRETTY_FUNCTION__, kABPersonPhoneProperty);

        MULTIBONUS_PROPERTIES = @[
              // Bonus items for which you get count^2 points, up to a maximum
              [__DBPropertyScorePair pairWithProperty: kABPersonPhoneProperty          score:  40],
              [__DBPropertyScorePair pairWithProperty: kABPersonEmailProperty          score:  15],
              [__DBPropertyScorePair pairWithProperty: kABPersonURLProperty            score:  25],
              [__DBPropertyScorePair pairWithProperty: kABPersonSocialProfileProperty  score:  45],
              [__DBPropertyScorePair pairWithProperty: kABPersonInstantMessageProperty score:  45]
              ];
    }
}


- (void) dealloc
{
    if (abContact)
    {
        CFRelease(abContact);
    }
}


#pragma mark -

- (ABRecordRef) contact
{
    return abContact;
}


- (NSString*) displayString
{
    NSString *displayString = @"- no contact name -";

    // get contact info
    NSString *firstName = (__bridge NSString*) (ABRecordCopyValue(abContact, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge NSString*) (ABRecordCopyValue(abContact, kABPersonLastNameProperty));

    if (lastName == nil)
    {
        if (firstName == nil)
        {
            //NSLog(@"%s === Warning ===  Odd contact:\n%@", __PRETTY_FUNCTION__, [self longDisplayString]);
        }
        else
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

    NSString *phoneNumber = [self phoneNumber];
    if (phoneNumber != nil)
    {
        displayString = [displayString stringByAppendingFormat: @" : %@", phoneNumber];
    }

    return displayString;
}


- (NSString*) longDisplayString
{
    // get contact info
    NSString *firstName = (__bridge NSString*) (ABRecordCopyValue(abContact, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge NSString*) (ABRecordCopyValue(abContact, kABPersonLastNameProperty));

    NSString *result = [NSString stringWithFormat: @"FirstName: %@\nLastName: %@\nPhone numbers: [\n", firstName, lastName];

    ABMultiValueRef phoneNumbers = ABRecordCopyValue(abContact, kABPersonPhoneProperty);
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


- (NSString*) phoneNumber
{
    NSString *result = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(abContact, kABPersonPhoneProperty);

    if (ABMultiValueGetCount(phoneNumbers) > 0)
    {
        result = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }

    return result;
}


- (void) setContact: (ABRecordRef) contact
{
}


- (void) updateScore
{
    // Ref: http://dbader.org/blog/guessing-favorite-contacts-ios

    const NSInteger favoriteScoreThreshhold     = 0;
    const NSInteger maxMultiValue               = 3;                            // give bonus for more, but not more than this many

    _score = 0;

    // Give a score penalty to contacts that belong to an organization
    // instead of a person.
    CFNumberRef contactKind = ABRecordCopyValue(abContact, kABPersonKindProperty);
    if (contactKind && contactKind != kABPersonKindPerson)
    {
        _score -= NON_PERSON_PENALTY;
    }

    if (contactKind)
    {
        CFRelease(contactKind);
    }

    // if no name, we're done
    NSString *firstName = (__bridge NSString*) (ABRecordCopyValue(abContact, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge NSString*) (ABRecordCopyValue(abContact, kABPersonLastNameProperty));

    if ((firstName == nil)
    &&  (lastName  == nil) )
    {
        return;     // fast bail
    }


    // Give score for all non-nil single-value properties
    // (e.g. first name, last name, ...).
    for (__DBPropertyScorePair *pair in SINGLEVALUE_PROPERTIES)
    {
        NSString *value = CFBridgingRelease(ABRecordCopyValue(abContact, pair.property));
        if (value)
        {
            _score += pair.score;
        }
    }

    // Give score for all non-empty multivalue properties
    for (__DBPropertyScorePair *pair in MULTIVALUE_PROPERTIES)
    {
        ABMultiValueRef valueRef = ABRecordCopyValue(abContact, pair.property);
        if (valueRef)
        {
            CFIndex count = ABMultiValueGetCount(valueRef);
            _score += count * pair.score;
            CFRelease(valueRef);
        }
    }

    // Give bonus points for multiples of really-good stuff (of to a max)
    for (__DBPropertyScorePair *pair in MULTIBONUS_PROPERTIES)
    {
        ABMultiValueRef valueRef = ABRecordCopyValue(abContact, pair.property);
        if (valueRef)
        {
            CFIndex count = ABMultiValueGetCount(valueRef);
            if (count > maxMultiValue)
            {
                count = maxMultiValue;
            }

            _score += count * count * pair.score;
            CFRelease(valueRef);
        }
    }

    // Give score if a contact has an associated image.
    if (ABPersonHasImageData(abContact))
    {
        _score += IMAGE_SCORE;
    }

    if (_score < favoriteScoreThreshhold)
    {
        _score = 0;
    }
}


@end