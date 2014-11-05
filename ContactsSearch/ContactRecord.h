//
//  ContactRecord.h
//  ContactsSearch
//
//  Created by Olie on 10/30/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AddressBook/AddressBook.h>


@interface ContactRecord : NSObject

+ (instancetype) contactWithABRecord: (ABRecordRef) abrecord;
+ (void) initialize;
+ (void) reinitialize;

- (ABRecordRef) contact;
- (NSString*) displayString;
- (NSString*) lastName;
- (NSString*) longDisplayString;
- (NSString*) phoneNumber;
- (void) updateScore;

- (void) debugGetScoreParams;

@property(readwrite, nonatomic) int lastNameBonus;
@property(readonly, nonatomic) int score;
@end
