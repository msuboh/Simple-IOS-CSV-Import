//
//  MHSDetailViewController.h
//  SimpleCSVImport
//
//  Created by Maher Suboh on 5/17/14.
//  Copyright (c) 2014 Maher Suboh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHSDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
