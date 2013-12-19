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

    NSString *root=@"http://popsicl-dav.cloudapp.net/webdav/";
    NSString *user=@"johnnyclem";
    NSString *password=@"glowkin22";
    
    _client = [[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:root] andUserName:user andPassword:password];
    
    LEOWebDAVPropertyRequest *request = [[LEOWebDAVPropertyRequest alloc] initWithPath:@"/"];
    [request setDelegate:self];
    [_client enqueueRequest:request];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_fileList[indexPath.row] isFolder]) {
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];        
    }
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
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - DAVKit
// The error can be a NSURLConnection error or a WebDAV error
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
}

// The resulting object varies depending on the request type
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

#pragma mark - ACConnect
//- (void)client:(ACWebDAVClient*)client loadedMetadata:(ACWebDAVItem*)item
//{
//    NSLog(@"metadata:%@",item);
//}



@end
