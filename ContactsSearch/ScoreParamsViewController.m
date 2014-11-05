//
//  ScoreParamsViewController.m
//  ContactsSearch
//
//  Created by Olie on 11/4/14.
//  Copyright (c) 2014 No Plan B Production. All rights reserved.
//

#import "ScoreParamsViewController.h"

@interface ScoreParamsViewController ()
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
        //[nc addObserver: self selector: @selector(keyboardHides:)    name: @"foo" object: nil];
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
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self.editing);

    [self.editing resignFirstResponder];
}


- (IBAction) okAction: (id) sender
{
}


#pragma mark - Keyboard

- (void)keyboardWillChange: (NSNotification*) notification
{
    NSDictionary *info = [notification userInfo];

    CGRect kFrame = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect vFrame = self.view.frame;
    [UIView animateWithDuration: 0.33 animations: ^{
        [self.view setFrame: CGRectMake(0, (kFrame.origin.y - vFrame.size.height), vFrame.size.width, vFrame.size.height)];
        }
     ];
}


//- (void) keyboardHides: (NSNotification *) notification
//{
//}


- (void)textFieldDidBeginEditing: (UITextField*) textField
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, textField);

    self.editing = textField;
}


@end
