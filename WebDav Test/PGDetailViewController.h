//
//  PGDetailViewController.h
//  WebDav Test
//
//  Created by John Clem on 12/18/13.
//  Copyright (c) 2013 Pretty Grest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
