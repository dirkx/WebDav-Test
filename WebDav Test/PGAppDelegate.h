//
//  PGAppDelegate.h
//  WebDav Test
//
//  Created by John Clem on 12/18/13.
//  Copyright (c) 2013 Pretty Grest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOWebDAVClient.h"
#import "WebDavTableViewController.h"

@interface PGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (nonatomic, strong) LEOWebDAVClient *client;

-(void)reconnectTo:(NSString *)host withUsername:(NSString *)username withPassword:(NSString *)password;
@end
