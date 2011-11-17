//
//  RIRetweetViewController.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/17/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIRetweetViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@implementation RIRetweetViewController

@synthesize eventObject = _eventObject;
@synthesize event = _event;
@synthesize textView = _textView;
@synthesize statusLbl = _statusLbl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureView
{
    if (_event.source)
    {
        if ([_event.source isEqualToString:@"today"])
        {
            [_textView setText:[NSString stringWithFormat:@"%@ #Arcosanti %@",[_event.title capitalizedString],_event.link]];
        }
        if ([_event.source isEqualToString:@"arcoTwitter"])
        {
           [_textView setText:[NSString stringWithFormat:@"RT @arcosanti %@",_event.storyHTML]];
        }
    }
    else
    {
            [_textView setText:[NSString stringWithFormat:@"RT @arcosanti Keep up the good work!"]];
    }
    
}

- (void)setEventObject:(id)newEventObject
{
    if (_eventObject != newEventObject) {
        _eventObject = newEventObject;
        self.event = newEventObject;
        // NSLog(@"Event: %@",_event);
    }
    
    [self configureView];
}

- (void)tweetComplete:(NSString *)text 
{
	//self.outputTextView.text = text;
    
    NSLog(@"tweet complete: %@",text);
    _statusLbl.hidden = NO;
    [_statusLbl setText:@"Thank You for Your Support!"]; 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TweetPosted" object:nil];
    tweetPosted = YES;
    
}

- (void)tweetError:(NSString *)text
{
    NSLog(@"tweet error: %@",text);
    _statusLbl.hidden = NO;
    [_statusLbl setText:@"Tweets must be 140 characters or Less!"];   
}

- (IBAction)sendCustomTweet:(id)sender {
    
    //prevent multiple tweets
    if (!(tweetPosted))
    {
        // Create an account store object.
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        // Create an account type that ensures Twitter accounts are retrieved.
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to use their Twitter accounts.
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                // Get the list of Twitter accounts.
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                
                // For the sake of brevity, we'll assume there is only one Twitter account present.
                // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
                if ([accountsArray count] > 0) {
                    // Grab the initial Twitter account to tweet from.
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    
                    // Create a request, which in this example, posts a tweet to the user's timeline.
                    // This example uses version 1 of the Twitter API.
                    // This may need to be changed to whichever version is currently appropriate.
                    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:_textView.text forKey:@"status"] requestMethod:TWRequestMethodPOST];
                    
                    // Set the account used to post the tweet.
                    [postRequest setAccount:twitterAccount];
                    
                    // Perform the request created above and create a handler block to handle the response.
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                    {
                        NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                        if ([urlResponse statusCode] == 200)
                        {
                            [self performSelectorOnMainThread:@selector(tweetComplete:) withObject:output waitUntilDone:NO];
                        }
                        else
                        {  
                            [self performSelectorOnMainThread:@selector(tweetError:) withObject:output waitUntilDone:NO];
                        }
                    }];
                }
            }
        }];
    }
}
/*

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
/*
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
