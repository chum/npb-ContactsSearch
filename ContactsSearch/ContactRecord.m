//
//  ContactRecord.m
//  ContactsSearch
//
//  Created by Olie on 10/30/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ContactRecord.h"


@interface ContactRecord()
@property(readwrite, nonatomic) int score;
@end



#pragma mark - DBFriendFinder specific

static NSInteger const IMAGE_SCORE = 20;
static NSInteger const NON_PERSON_PENALTY = 100;

// Lookup tables for properties and their score values.
// Single and multivalue properties are treated differently.
static NSArray *SINGLEVALUE_PROPERTIES = nil;
static NSArray *MULTIVALUE_PROPERTIES = nil;

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

- (instancetype) initWithProperty:(ABPropertyID)property score:(NSInteger)score {
    self = [super init];
    if (!self) {
        return nil;
    }

    _property = property;
    _score = score;

    return self;
}

+ (instancetype) pairWithProperty:(ABPropertyID)property score:(NSInteger)score {
    return [[__DBPropertyScorePair alloc] initWithProperty:property score:score];
}

@end


#pragma mark -

@implementation ContactRecord

static const NSInteger favoriteScoreThreshhold      = 300;

+ (instancetype) contactWithABRecord: (ABRecordRef) abrecord
{
    ContactRecord *result = [self new];
    result.contact = abrecord;

    return result;
}


+ (void) initialize {
    if (SINGLEVALUE_PROPERTIES == nil)
    {
        SINGLEVALUE_PROPERTIES = @[
               // Contacts with nicknames and birthdays are likely to be more important.
               [__DBPropertyScorePair pairWithProperty: kABPersonNicknameProperty           score: 100],
               [__DBPropertyScorePair pairWithProperty: kABPersonBirthdayProperty           score:  50],
               [__DBPropertyScorePair pairWithProperty: kABPersonFirstNameProperty          score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonLastNameProperty           score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonMiddleNameProperty         score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonPrefixProperty             score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonSuffixProperty             score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonFirstNamePhoneticProperty  score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonMiddleNamePhoneticProperty score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonOrganizationProperty       score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonJobTitleProperty           score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonDepartmentProperty         score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonPrefixProperty             score:  10],
               [__DBPropertyScorePair pairWithProperty: kABPersonNoteProperty               score:  10]
               ];
    }

    if (MULTIVALUE_PROPERTIES == nil)
    {
        MULTIVALUE_PROPERTIES = @[
              // Related names and associated dates (anniversaries) are likely to indicate
              // close relationships. Also, phone numbers and addresses rank higher than emails
              // and IM profiles.
              [__DBPropertyScorePair pairWithProperty: kABPersonRelatedNamesProperty   score: 300],
              [__DBPropertyScorePair pairWithProperty: kABPersonDateProperty           score: 300],
              [__DBPropertyScorePair pairWithProperty: kABPersonPhoneProperty          score:  40],
              [__DBPropertyScorePair pairWithProperty: kABPersonAddressProperty        score:  40],
              [__DBPropertyScorePair pairWithProperty: kABPersonEmailProperty          score:  20],
              [__DBPropertyScorePair pairWithProperty: kABPersonURLProperty            score:  10],
              [__DBPropertyScorePair pairWithProperty: kABPersonSocialProfileProperty  score:  10],
              [__DBPropertyScorePair pairWithProperty: kABPersonInstantMessageProperty score:  10]
              ];
    }
}


- (void) setContact: (ABRecordRef) contact
{
    _contact = contact;

    [self updateScore];
}


- (void) updateScore
{
    _score = 0;

    // Give a score penalty to contacts that belong to an organization
    // instead of a person.
    CFNumberRef contactKind = ABRecordCopyValue(_contact, kABPersonKindProperty);
    if (contactKind && contactKind != kABPersonKindPerson)
    {
        _score -= NON_PERSON_PENALTY;
    }

    if (contactKind)
    {
        CFRelease(contactKind);
    }

    // Give score for all non-nil single-value properties
    // (e.g. first name, last name, ...).
    for (__DBPropertyScorePair *pair in SINGLEVALUE_PROPERTIES)
    {
        NSString *value = CFBridgingRelease(ABRecordCopyValue(_contact, pair.property));
        if (value)
        {
            _score += pair.score;
        }
    }

    // Give score for all non-empty multivalue properties
    // (e.g. phone numbers, email addresses, ...).
    for (__DBPropertyScorePair *pair in MULTIVALUE_PROPERTIES)
    {
        ABMultiValueRef valueRef = ABRecordCopyValue(_contact, pair.property);
        if (valueRef)
        {
            _score += ABMultiValueGetCount(valueRef) * pair.score;
            CFRelease(valueRef);
        }
    }

    // Give score if a contact has an associated image.
    if (ABPersonHasImageData(_contact))
    {
        _score += IMAGE_SCORE;
    }
}


@end
