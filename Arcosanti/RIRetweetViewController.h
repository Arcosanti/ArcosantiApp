//
//  RIRetweetViewController.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/17/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface RIRetweetViewController : UIViewController
{
    bool tweetPosted;
}
@property (strong, nonatomic) id eventObject;
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *statusLbl;

- (IBAction)sendCustomTweet:(id)sender;
- (void)tweetComplete:(NSString *)text;
- (void)tweetError:(NSString *)text;

@end
