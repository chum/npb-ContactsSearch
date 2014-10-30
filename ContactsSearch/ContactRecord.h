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

- (ABRecordRef) contact;
- (NSString*) displayString;
- (NSString*) longDisplayString;
- (NSString*) phoneNumber;

@property(readonly, nonatomic) int score;
@end
