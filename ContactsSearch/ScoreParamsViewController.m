//
//  ScoreParamsViewController.m
//  ContactsSearch
//
//  Created by Olie on 11/4/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ScoreParamsViewController.h"

@interface ScoreParamsViewController ()
{
    CGRect kFrame;
}
@property(weak, nonatomic) UITextField *editing;
@end


@implementation ScoreParamsViewController

#pragma mark - Lifecycle

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver: self selector: @selector(keyboardWillChange:) name: UIKeyboardWillChangeFrameNotification object: nil];
    }

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Fix silly UILabel "Automatic Preferred Max Layout Width" warning
    for (UIView *oneView in self.view.subviews)
    {
        if ([oneView isKindOfClass: [UILabel class]])
        {
            UILabel *oneLabel = (UILabel*) oneView;
            oneLabel.numberOfLines = 0;
        }
    }

    // set up sort-param fields.
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey: UD_SORT_THRESHOLD] == nil)
    {
        [self setDefaults];
    }
    else
    {
        self.nonPersonField.text    = [[ud objectForKey: UD_SORT_NON_PERSON] stringValue];
        self.noPhoneField.text      = [[ud objectForKey: UD_SORT_NO_PHONE] stringValue];
        self.imageBonusField.text   = [[ud objectForKey: UD_SORT_IMAGE] stringValue];
        self.relatedBonusField.text = [[ud objectForKey: UD_SORT_RELATED] stringValue];
        self.birthdayField.text     = [[ud objectForKey: UD_SORT_BIRTHDAY] stringValue];
        self.phoneNumberField.text  = [[ud objectForKey: UD_SORT_PHONE_NUMBER] stringValue];
        self.sameAsContactField.text= [[ud objectForKey: UD_SORT_SAME_AS_CONTACT] stringValue];
        self.threshholdField.text   = [[ud objectForKey: UD_SORT_THRESHOLD] stringValue];
        self.squaringBonusField.text= [[ud objectForKey: UD_SORT_SQUARING_MAX] stringValue];
    }
}


#pragma mark - Support

- (void) setDefaults
{
    self.nonPersonField.text    = @"100";
    self.noPhoneField.text      = @"1000";
    self.imageBonusField.text   = @"20";
    self.relatedBonusField.text = @"200";
    self.birthdayField.text     = @"250";
    self.phoneNumberField.text  = @"50";
    self.sameAsContactField.text= @"200";
    self.threshholdField.text   = @"0";
    self.squaringBonusField.text= @"3";
}


#pragma mark - Actions

- (IBAction) cancelAction: (id) sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}


- (IBAction) hideKeyboard: (id) sender
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, self.editing);

    [self.editing resignFirstResponder];
}


- (IBAction) okAction: (id) sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [ud setInteger: [self.nonPersonField.text     intValue] forKey: UD_SORT_NON_PERSON];
    [ud setInteger: [self.noPhoneField.text       intValue] forKey: UD_SORT_NO_PHONE];
    [ud setInteger: [self.imageBonusField.text    intValue] forKey: UD_SORT_IMAGE];
    [ud setInteger: [self.relatedBonusField.text  intValue] forKey: UD_SORT_RELATED];
    [ud setInteger: [self.birthdayField.text      intValue] forKey: UD_SORT_BIRTHDAY];
    [ud setInteger: [self.phoneNumberField.text   intValue] forKey: UD_SORT_PHONE_NUMBER];
    [ud setInteger: [self.squaringBonusField.text intValue] forKey: UD_SORT_SQUARING_MAX];
    [ud setInteger: [self.sameAsContactField.text intValue] forKey: UD_SORT_SAME_AS_CONTACT];
    [ud setInteger: [self.threshholdField.text    intValue] forKey: UD_SORT_THRESHOLD];

    [ud synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName: SORT_PARAMS_UPDATED object: self];

    [self dismissViewControllerAnimated: YES completion: nil];
}


- (IBAction) resetAction: (id) sender
{
    [self setDefaults];
}


#pragma mark - Keyboard

- (void) adjustForKeyboard
{
    CGRect vFrame = self.view.frame;
    CGRect eFrame = self.editing.frame;

    const CGFloat spacer = 50;
    CGFloat eBottom = eFrame.origin.y + eFrame.size.height + spacer;

    CGRect newFrame = self.view.bounds;

    if ((eBottom > kFrame.origin.y)
    ||  (kFrame.origin.y >= vFrame.size.height) )
    {
        newFrame = CGRectMake(0, (kFrame.origin.y - vFrame.size.height), vFrame.size.width, vFrame.size.height);
    }

    [UIView animateWithDuration: 0.33
                     animations: ^{
                         [self.view setFrame: newFrame];
                     }
     ];
}


- (void)keyboardWillChange: (NSNotification*) notification
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, notification.name);

    NSDictionary *info = [notification userInfo];

    kFrame = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self adjustForKeyboard];
}


- (void)textFieldDidBeginEditing: (UITextField*) textField
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, textField);

    self.editing = textField;
    [self adjustForKeyboard];
}


@end
