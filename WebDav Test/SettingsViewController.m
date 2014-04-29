//
//  SettingsViewController.m
//  WebDav Test
//
//  Created by Dirk-Willem van Gulik on 29-04-14.
//  Copyright (c) 2014 Pretty Grest. All rights reserved.
//

#import "SettingsViewController.h"
#import "PGAppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateSettings];
}

-(void)updateSettings {
    PGAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    LEOWebDAVClient * client = appDelegate.client;
    
    [self.showPassword setOn:NO];
    [self.password setSecureTextEntry:!self.showPassword.on];

    self.url.text = client.rootURL.absoluteString;
    self.username.text = client.userName;
    self.password.text = client.password;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// We let the user tab/return through all 3 fields - and
// close the keyboard on the last (as otherwise you cannot
// really hit the 'ok' button as easily.
//
- (BOOL)textFieldShouldReturn:(UIView *)sender {

    UIView *view = [self.view viewWithTag:sender.tag + 1];
    if (!view)
        [sender resignFirstResponder];
    else
        [view becomeFirstResponder];
    
    return YES;
}

-(IBAction)showPasswordSwitchChanged:(id)sender {
    [self.password setSecureTextEntry:!self.showPassword.on];
}

-(IBAction)cancel:(id)sender {
    [self updateSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)OK:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    PGAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate reconnectTo:self.url.text withUsername:self.username.text withPassword:self.password.text];
};

@end