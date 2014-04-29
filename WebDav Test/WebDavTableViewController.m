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

#import "PGAppDelegate.h"


@interface WebDavTableViewController ()
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSMutableArray *folderList;
@property (nonatomic, strong) NSString *recentError;
@property (nonatomic, strong) UIActivityIndicatorView *activityViewer;
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
#if 0
    if ([self.navigationController.viewControllers count]==1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(settingsButtonPressed:)];
    };
#endif
    
    self.activityViewer = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    NSMutableArray * btns = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    [btns addObject:[[UIBarButtonItem alloc] initWithCustomView:self.activityViewer]];
    self.navigationItem.rightBarButtonItems = btns;
    [self.activityViewer stopAnimating];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents: UIControlEventValueChanged];

    [(PGAppDelegate *)[UIApplication sharedApplication].delegate addObserver:self
                       forKeyPath:@"client"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    
    [self refreshAction:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma some UIRefreshControl stuff to detect reloads

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"client"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];

        self.fileList = nil;
        [self.tableView reloadData];
        
        [self refreshAction:self];
    }
}

-(void)refreshAction:(id)sender {
    [self.refreshControl beginRefreshing];

    if (sender != self.refreshControl)
        [self.activityViewer startAnimating];

    self.recentError = nil;

    LEOWebDAVPropertyRequest *request = [[LEOWebDAVPropertyRequest alloc] initWithPath:_rootPath];
    [request setDelegate:self];
    
    [((PGAppDelegate *)[UIApplication sharedApplication].delegate).client enqueueRequest:request];
}

-(void)resetRefresher:(id)sender {
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"fetching"];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX(_folderList.count, 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.recentError)
        return 1;

    return _fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.recentError){
        static NSString *ErrorCellIdentifier = @"ErrorCell";
        UITableViewCell *errorCell = [tableView dequeueReusableCellWithIdentifier:ErrorCellIdentifier forIndexPath:indexPath];
        
        errorCell.textLabel.text = @"no data - fetch failed";
        [errorCell.textLabel setTextColor:[UIColor grayColor]];
        [errorCell.textLabel setTextAlignment:NSTextAlignmentCenter];

        errorCell.detailTextLabel.text = self.recentError;

        return errorCell;
    }
    
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
    if (self.recentError)
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        LEOWebDAVItem *item = _fileList[indexPath.row];
        LEOWebDAVDeleteRequest *deleteRequest = [[LEOWebDAVDeleteRequest alloc] initWithPath:item.relativeHref];
        [deleteRequest setDelegate:self];

        [((PGAppDelegate *)[UIApplication sharedApplication].delegate).client enqueueRequest:deleteRequest];

        [_fileList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.recentError)
        return;

    LEOWebDAVItem *item = _fileList[indexPath.row];
    
    if (item.isFolder) {
        UIStoryboard *sharedStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        WebDavTableViewController *webDavVC = [sharedStoryboard instantiateViewControllerWithIdentifier:@"WebDavVC"];
        webDavVC.navigationItem.title = item.displayName;
        webDavVC.rootPath = item.relativeHref;
        
        [self.navigationController pushViewController:webDavVC animated:YES];

    } else //if ([item.contentType isEqualToString:@"text/plain"])
    {
        PGDetailViewController * pgvc = [[PGDetailViewController alloc] init];
        pgvc.detailItem = item;
        [self.navigationController pushViewController:pgvc animated:YES];        
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

-(void)request:(LEOWebDAVRequest *)request didReceivedProgress:(float)percent {
    if (percent>0)
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02.f%%", percent*100]];
}

-(void)request:(LEOWebDAVRequest *)request didSendBodyData:(NSUInteger)percent {
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"receiving"];
}
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self performSelectorInBackground:@selector(resetRefresher:) withObject:self];
    
    self.recentError = [error localizedDescription];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    [self.activityViewer stopAnimating];
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl endRefreshing];
    [self.activityViewer stopAnimating];
    [self performSelectorInBackground:@selector(resetRefresher:) withObject:self];

    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
        _fileList = (NSMutableArray *)result;
        [self.tableView reloadData];
        
    } else if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]] && result){
        // Kind of should not happen here - relegated to the PGDetailViewController
        //
        NSLog(@"Downloaded: %@", result);
    } else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        NSLog(@"Deleted: %@ %@", [result class], result);
    }
}

@end
