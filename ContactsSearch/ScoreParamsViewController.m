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
