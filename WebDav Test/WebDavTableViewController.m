//
//  WebDavTableViewController.m
//  LEOWebDAV
//
//  Created by John Clem on 12/18/13.
//  Copyright (c) 2013 SAE. All rights reserved.
//

#import "WebDavTableViewController.h"
#import "LEOWebDAVClient.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEOWebDAVDeleteRequest.h"
#import "PGDetailViewController.h"

@interface WebDavTableViewController ()

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSMutableArray *folderList;
@property (nonatomic, strong) LEOWebDAVClient *client;

@end

@implementation WebDavTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = NO;
     self.navigationItem.rightBarButtonItem = self.editButtonItem;

    NSString *root = @"http://popsicl-dav.cloudapp.net/webdav/";
    NSString *user = @"johnnyclem";
    NSString *password = @"glowkin22";
    
    _client = [[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:root] andUserName:user andPassword:password];
    
    LEOWebDAVPropertyRequest *request = [[LEOWebDAVPropertyRequest alloc] initWithPath:_rootPath];
    [request setDelegate:self];
    [_client enqueueRequest:request];
    NSLog(@"Requesting Contents Of: %@", _rootPath);

//    LEOWebDAVDownloadRequest *downRequest = [[LEOWebDAVDownloadRequest alloc] initWithPath:@"/New-Clients.m4a"];
//    [downRequest setDelegate:self];
//    [_client enqueueRequest:downRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX(_folderList.count, 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    LEOWebDAVItem *item = _fileList[indexPath.row];
    if (item.isFolder) {
        cell.imageView.image = [UIImage imageNamed:@"folder"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"file"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = item.displayName;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        LEOWebDAVItem *item = _fileList[indexPath.row];
        LEOWebDAVDeleteRequest *deleteRequest = [[LEOWebDAVDeleteRequest alloc] initWithPath:item.relativeHref];
        [deleteRequest setDelegate:self];
        [_client enqueueRequest:deleteRequest];

        [_fileList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LEOWebDAVItem *item = _fileList[indexPath.row];
    
    if (item.isFolder) {
        UIStoryboard *sharedStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WebDavTableViewController *webDavVC = [sharedStoryboard instantiateViewControllerWithIdentifier:@"WebDavVC"];
        webDavVC.navigationItem.title = item.displayName;
        webDavVC.rootPath = item.relativeHref;
        [self.navigationController pushViewController:webDavVC animated:YES];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    LEOWebDAVItem *item = _fileList[indexPath.row];

    if (item.isFolder && [segue.identifier isEqualToString:@"showFolderContents"]) {
        [[[segue destinationViewController] navigationItem] setTitle:item.displayName];
        [[segue destinationViewController] setRootPath:item.relativeHref];
    }
}

#pragma mark - DAVKit

- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(NSMutableArray *)result
{
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
        _fileList = result;
        [self.tableView reloadData];
    } else if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]] && result){
        NSLog(@"Downloaded: %@", result);
    } else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        NSLog(@"Deleted: %@", result);
    }
}

@end
