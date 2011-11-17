//
//  RIDetailViewController.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface RIDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) id URLitem;
@property (strong, nonatomic) id eventObject;
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) id titleTextItem;
@property (strong, nonatomic) NSURL *externalURL;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;


//- (void)canTweetStatus;

//-(void)setWebViewContent:(NSString *)html;

@end
