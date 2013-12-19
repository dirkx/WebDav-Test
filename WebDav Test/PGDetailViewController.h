//
//  PGDetailViewController.h
//  WebDav Test
//
//  Created by John Clem on 12/18/13.
//  Copyright (c) 2013 Pretty Grest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOWebDAVRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEOWebDAVDeleteRequest.h"

@interface PGDetailViewController : UIViewController

@property (strong, nonatomic) LEOWebDAVItem *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
