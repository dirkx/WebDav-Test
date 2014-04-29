//
//  SettingsViewController.h
//  WebDav Test
//
//  Created by Dirk-Willem van Gulik on 29-04-14.
//  Copyright (c) 2014 Pretty Grest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property  (assign,nonatomic) IBOutlet UITextField * url;
@property  (assign,nonatomic) IBOutlet UITextField * username;
@property  (assign,nonatomic) IBOutlet UITextField * password;
@property  (assign,nonatomic) IBOutlet UISwitch * showPassword;

-(IBAction)showPasswordSwitchChanged:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)OK:(id)sender;
@end
