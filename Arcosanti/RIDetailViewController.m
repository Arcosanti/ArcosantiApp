//
//  RIDetailViewController.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIDetailViewController.h"

@interface RIDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _detailDescriptionLabel.hidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
     //   [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.masterPopoverController = nil;
}

@end
