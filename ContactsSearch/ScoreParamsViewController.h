//
//  ScoreParamsViewController.h
//  ContactsSearch
//
//  Created by Olie on 11/4/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreParamsViewController : UIViewController
    <UITextFieldDelegate>
@property(weak, nonatomic) IBOutlet UITextField *nonPersonField;
@property(weak, nonatomic) IBOutlet UITextField *noPhoneField;
@property(weak, nonatomic) IBOutlet UITextField *imageBonusField;
@property(weak, nonatomic) IBOutlet UITextField *relatedBonusField;
@property(weak, nonatomic) IBOutlet UITextField *birthdayField;
@property(weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property(weak, nonatomic) IBOutlet UITextField *sameAsMeField;
@property(weak, nonatomic) IBOutlet UITextField *sameAsContactField;
@property(weak, nonatomic) IBOutlet UITextField *threshholdField;
@end
