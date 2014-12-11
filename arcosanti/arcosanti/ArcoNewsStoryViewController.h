//
//  DetailViewController.h
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/22/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArcoNewsStoryViewController : UIViewController

@property (strong, nonatomic) id detailItem;


@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

