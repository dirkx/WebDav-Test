//
//  PGDetailViewController.m
//  WebDav Test
//
//  Created by John Clem on 12/18/13.
//  Copyright (c) 2013 Pretty Grest. All rights reserved.
//

#import "PGDetailViewController.h"
#import "PGAppDelegate.h"

@interface PGDetailViewController () <UIWebViewDelegate, LEOWebDAVRequestDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) UIActivityIndicatorView *activityViewer;

- (void)configureView;
@end

@implementation PGDetailViewController

#pragma mark - Managing the detail item

-(id)completeInit {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;

    self.activityViewer = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityViewer];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self completeInit];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return [self completeInit];
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.title = self.detailDescriptionLabel.text = [self.detailItem displayName];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

-(void)viewDidAppear:(BOOL)animated {    
    LEOWebDAVDownloadRequest *request = [[LEOWebDAVDownloadRequest alloc] initWithPath:self.detailItem.relativeHref];
    [request setDelegate:self];
    
    [((PGAppDelegate *)[UIApplication sharedApplication].delegate).client enqueueRequest:request];
    [self.activityViewer startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebKit

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Display failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
    [self.activityViewer stopAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView setScalesPageToFit:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scrolly:) userInfo:nil repeats:NO];
    [self.activityViewer stopAnimating];
}

-(void)scrolly:(id)sender {
    if ([self.detailItem.contentType isEqualToString:@"application/pdf"])
        [self.webView.scrollView setContentOffset:CGPointMake(0, -62) animated:YES];
}

#pragma mark - DAVKit

-(void)request:(LEOWebDAVRequest *)request didReceivedProgress:(float)percent {
}

-(void)request:(LEOWebDAVRequest *)request didSendBodyData:(NSUInteger)percent {
}

- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    [self.webView loadHTMLString:[error localizedDescription] baseURL:nil];
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]] && result) {
        
        [self.webView loadData:result MIMEType:self.detailItem.contentType
              textEncodingName:@"utf8" // check if we can somehow get this from headers.
                       baseURL:self.detailItem.rootURL];
    }
}

@end
