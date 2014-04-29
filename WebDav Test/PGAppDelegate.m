//
//  PGAppDelegate.m
//  WebDav Test
//
//  Created by John Clem on 12/18/13.
//  Copyright (c) 2013 Pretty Grest. All rights reserved.
//

#import "PGAppDelegate.h"
#import "WebDavTableViewController.h"

@implementation PGAppDelegate
@synthesize client;

+(void)initialize {
    NSString *root = @"<none>";
    NSString *username = @"<none>";
    NSString *password = @"";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
                                 @"username" : username,
                                 @"password": password,
                                 @"root" : root
                                 }
     ];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [self reconnectTo:[defaults objectForKey:@"root"]
         withUsername:[defaults objectForKey:@"username"]
         withPassword:[defaults objectForKey:@"password"]];
    
        return YES;
}

-(void)reconnectTo:(NSString *)root withUsername:(NSString *)username withPassword:(NSString *)password {

    if (!root || !username || !password)
        return;
    
    NSURL * url = [NSURL URLWithString:root];
    if (!url)
        return;
    
    if ([self.client.userName isEqualToString:username] && [self.client.password isEqualToString:password] && [self.client.rootURL isEqual:url])
        return;

    [self.client cancelRequest];

    self.client = [[LEOWebDAVClient alloc] initWithRootURL:url andUserName:username andPassword:password];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:username forKey:@"username"];
    [defaults setValue:password forKey:@"password"];
    [defaults setValue:root forKey:@"root"];
    [defaults synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
