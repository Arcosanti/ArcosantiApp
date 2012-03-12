//
//  RIDetailViewController.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIDetailViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "RIAppDelegate.h"


@interface RIDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *tweetPopoverController;
@property (strong, nonatomic) UIStoryboardPopoverSegue *tweetPopoverSegue;
- (void)configureView;
@end

@implementation RIDetailViewController

@synthesize detailItem = _detailItem;
@synthesize titleTextItem = _titleTextItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize webView = _webView;
@synthesize URLitem = _URLitem;
@synthesize externalURL = _externalURL;
@synthesize eventObject = _eventObject;
@synthesize event = _event;
@synthesize tweetPopoverController = _tweetPopoverController;
@synthesize tweetPopoverSegue = _tweetPopoverSegue;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        _URLitem = nil;
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }     
    
    
}

- (void)setEventObject:(id)newEventObject
{
    if (_eventObject != newEventObject) {
        _eventObject = newEventObject;
        self.event = newEventObject;
       // NSLog(@"Event: %@",_event);
    }
}

- (void)setTitleTextItem:(id)newTitleText
{
    if (_titleTextItem != newTitleText) 
    {
        _titleTextItem = newTitleText;
        //NSLog(@"setting title text: %@",_titleTextItem);
        self.detailDescriptionLabel.hidden = NO;
    }      
}
/*
-(void)setURLWebViewContent:(NSString *)html
{
    NSURL *wwwArco = [NSURL URLWithString:@"http://www.arcosanti.org"];
    [self.webView loadHTMLString:html baseURL:wwwArco];
    
   // NSLog(@"setting webview content %@",html);
    
}
*/
- (void)setURLitem:(id)newURLitem
{
    _detailItem = nil;
    _URLitem = newURLitem;
    self.externalURL = [[NSURL alloc]initWithString:[newURLitem description]];
    [self configureView];
}


- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.detailDescriptionLabel.hidden = NO;
        self.detailDescriptionLabel.text = [self.titleTextItem description];
        NSURL *wwwArco = [NSURL URLWithString:@"http://www.arcosanti.org"];
       // NSLog(@"detail webview html: %@",[self.detailItem description]); 
        [self.webView loadHTMLString:[self.detailItem description] baseURL:wwwArco];
    }
    
    if (self.URLitem)
    {
        //NSLog(@"URL Request: %@",_externalURL);
        NSURLRequest *linkRequest = [[NSURLRequest alloc]initWithURL:_externalURL];
        [self.webView loadRequest:linkRequest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Button Actions

- (void)displayText:(NSString *)text {
//	self.outputTextView.text = text;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTweetPopover"]) 
    {
        
        NSLog(@"%@",[segue destinationViewController]);
        self.tweetPopoverSegue = (UIStoryboardPopoverSegue*) segue;
        
        //[[segue destinationViewController] setDelegate:self];
        
        //self.tweetPopoverController = [segue destinationViewController];
        
        [[segue destinationViewController] setEventObject:_eventObject]; 
    }
}


#pragma mark - View lifecycle

- (void)loadStartupDetailView
{
    RIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //find the latest today entry to load
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init]; 
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:appDelegate.managedObjectContext]];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"(source like %@)", @"today"];
	[fetchRequest setPredicate:pre];
    
    NSError *error = nil;
	NSArray *fetchResults = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchResults count] > 0) 
    {
        Event *latestToday = [fetchResults objectAtIndex:0];
        
        NSURL *arcoWWW = [NSURL URLWithString:@"http://www.arcosanti.org"];
        //NSURL *arcoWWW = [NSURL URLWithString:NSHomeDirectory()];
        NSLog(@"url base: %@",arcoWWW);
        
        NSString *webPage = [NSString stringWithFormat:@"<html><STYLE TYPE=\"text/css\"><!-- BODY {border:1px;border-color:#FFFFFF;font-family:\"Helvetica Neue\"; font-size:20px;margin-top:0px;margin-right:18px;margin-left:18px} img{padding:18px;padding-left:0px;padding-top:5px;}.headlineTextBox {background:#AAAAAA;padding-bottom:2px;padding-left:5px;margin-bottom:5px;margin-left:-18px;margin-right:-18px;font-size:32px;font-weight:bold;} --></STYLE><body><div class=\"headlineTextBox\">%@</div>%@</body></html>",[latestToday.title capitalizedString] , latestToday.storyHTML];
        [self.webView loadHTMLString:webPage baseURL:arcoWWW];
        [self setEventObject:latestToday];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _detailDescriptionLabel.hidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
    [self loadStartupDetailView];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
     //   [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissTweetPopover:) 
                                                 name:@"TweetPosted"
                                               object:nil];
    
}

-(void)dismissTweetPopover:(NSNotification *)notif
{
    //[self.tweetPopoverSegue.popoverController dismissPopoverAnimated:YES];
    NSLog(@"dissmiss tweet");
}
  

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Menu", @"Menu");
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:NO];
    self.navigationItem.title = @"Arcosanti: Architecture and Ecology";
    self.masterPopoverController = popoverController;
    
   
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    self.masterPopoverController = nil;
}

@end
