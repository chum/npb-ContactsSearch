//
//  ScoreParamsViewController.h
//  ContactsSearch
//
//  Created by Olie on 11/4/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SORT_PARAMS_UPDATED         @"sort-params-updated"

#define UD_SORT_NON_PERSON          @"sort-non-person"
#define UD_SORT_NO_PHONE            @"sort-no-phone"
#define UD_SORT_IMAGE               @"sort-image"
#define UD_SORT_RELATED             @"sort-related"
#define UD_SORT_BIRTHDAY            @"sort-birthday"
#define UD_SORT_PHONE_NUMBER        @"sort-phone#"
#define UD_SORT_SAME_AS_CONTACT     @"sort-same-as-contact"
#define UD_SORT_THRESHOLD           @"sort-threshold"
#define UD_SORT_SQUARING_MAX        @"sort-squaring-max"

@interface ScoreParamsViewController : UIViewController
    <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField *nonPersonField;
@property(weak, nonatomic) IBOutlet UITextField *noPhoneField;
@property(weak, nonatomic) IBOutlet UITextField *imageBonusField;
@property(weak, nonatomic) IBOutlet UITextField *relatedBonusField;
@property(weak, nonatomic) IBOutlet UITextField *birthdayField;
@property(weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property(weak, nonatomic) IBOutlet UITextField *squaringBonusField;
@property(weak, nonatomic) IBOutlet UITextField *sameAsContactField;
@property(weak, nonatomic) IBOutlet UITextField *threshholdField;
@end
