//
//  RIMasterViewController.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIMasterViewController.h"

#import "RIDetailViewController.h"
#import "RIMasterCellView.h"
#import "Event.h"
#import "RICoverPageViewController.h"
#import "RIAppDelegate.h"

@interface RIMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RIMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize masterCellView = _masterCellView;
@synthesize coverPage = _coverPage;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
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

    
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (RIDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    // Set up the edit and add buttons.
   // self.navigationItem.leftBarButtonItem = self.editButtonItem;

   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(checkForUpdates)];
    
   self.navigationItem.rightBarButtonItem = addButton;


    UIDevice *device = [UIDevice currentDevice];					//Get the device object
	[device beginGeneratingDeviceOrientationNotifications];			//Tell it to start monitoring the accelerometer for orientation
	
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
	
    [nc addObserver:self											//Add yourself as an observer
		   selector:@selector(orientationChanged:)
			   name:UIDeviceOrientationDidChangeNotification
			 object:device];
    

}

- (void)orientationChanged:(NSNotification *)note
{
	NSLog(@"Orientation  has changed: %d", [[note object] orientation]);
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) || 
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)) 
    {
        if ([_detailViewController.webView isHidden])
        {
            
            self.detailViewController.webView.hidden = NO;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            
            Event *selectedEvent = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            
            NSURL *arcoWWW = [NSURL URLWithString:@"http://www.arcosanti.org"];
            //NSURL *arcoWWW = [NSURL URLWithString:NSHomeDirectory()];
            NSLog(@"url base: %@",arcoWWW);
            NSString *webPage = [NSString stringWithFormat:@"<html><STYLE TYPE=\"text/css\"><!-- BODY {border:1px;border-color:#FFFFFF;font-family:\"Helvetica Neue\"; font-size:20px;margin-top:0px;margin-right:18px;margin-left:18px} img{padding:18px;padding-left:0px;padding-top:5px;}.headlineTextBox {background:#AAAAAA;padding-bottom:2px;padding-left:5px;margin-bottom:5px;margin-left:-18px;margin-right:-18px;font-size:32px;font-weight:bold;} --></STYLE><body><div class=\"headlineTextBox\">%@</div>%@</body></html>",[selectedEvent.title capitalizedString] , selectedEvent.storyHTML];
            [self.detailViewController.webView loadHTMLString:webPage baseURL:arcoWWW];
            self.detailViewController.webView.hidden = NO;
   
        }
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
   /* 
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && (!(notFirstTimeLaunch)))
    {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil]; 
        
        self.coverPage = [storyboard  instantiateViewControllerWithIdentifier:@"RICoverPageViewController"];
        
        NSLog(@"cover page");
        [self presentModalViewController:_coverPage animated:NO];
        
    }
    */
    
    notFirstTimeLaunch = YES;

     
    [super viewDidAppear:animated];
    

}

-(void)checkForUpdates
{
    RIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate.arcoTweetDelegate getLatestTweets];
    [appDelegate.todayFeedDelegate getLatestEvents];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event= [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([event.source isEqualToString:@"arcoTwitter"])
    {
        return 85;
    }
    else
    {
        return 103;
    };
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"MasterCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Event *event= [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([event.source isEqualToString:@"arcoTwitter"])
    {
        CellIdentifier = @"TweetCell";
    }
    else
    {
        CellIdentifier = @"MasterCell";
    }
   
    RIMasterCellView *cell = (RIMasterCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /*
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RIMasterCellView" owner:self options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (RIMasterCellView *) currentObject;
                break;
            }
        }
    }
   
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"RIMasterCellView" owner:self options:nil];
        cell = _masterCellView;
        self.masterCellView = nil;
    }

   // NSLog(@"Cell: %@",cell);
   
    Event *event= [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (event.title)
    {
        cell.storyTitleLbl.text = event.title;
    }
    if (event.storyText)
    {
        cell.storyDescLbl.text = event.storyText;
    }
    if (event.previewImagePath)
    {
        cell.articleImageView1.image = [[UIImage alloc]initWithContentsOfFile:event.previewImagePath];
    }
    
    */
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


//ipad with split view controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Event *selectedEvent = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //self.detailViewController.detailItem = selectedEvent.title;
        
        if ([selectedEvent.source isEqualToString:@"today"])
        {
            NSURL *arcoWWW = [NSURL URLWithString:@"http://www.arcosanti.org"];
            //NSURL *arcoWWW = [NSURL URLWithString:NSHomeDirectory()];
            NSLog(@"url base: %@",arcoWWW);
            NSString *webPage = [NSString stringWithFormat:@"<html><STYLE TYPE=\"text/css\"><!-- BODY {border:1px;border-color:#FFFFFF;font-family:\"Helvetica Neue\"; font-size:20px;margin-top:0px;margin-right:18px;margin-left:18px} img{padding:18px;padding-left:0px;padding-top:5px;}.headlineTextBox {background:#AAAAAA;padding-bottom:2px;padding-left:5px;margin-bottom:5px;margin-left:-18px;margin-right:-18px;font-size:32px;font-weight:bold;} --></STYLE><body><div class=\"headlineTextBox\">%@</div>%@</body></html>",[selectedEvent.title capitalizedString] , selectedEvent.storyHTML];
            [self.detailViewController.webView loadHTMLString:webPage baseURL:arcoWWW];
            self.detailViewController.webView.hidden = NO;
        }
        if ([selectedEvent.source isEqualToString:@"arcoTwitter"])
        {
            NSURL *linkURL = [NSURL URLWithString:selectedEvent.link];
            NSURLRequest *linkRequest = [[NSURLRequest alloc]initWithURL:linkURL];
            
           
            [self.detailViewController.webView loadRequest:linkRequest];
            self.detailViewController.webView.hidden = NO;
        }
       // [self.detailViewController.webView loadHTMLString:selectedEvent.storyHTML baseURL:nil];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSegue: %@",[segue identifier]);
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Event *selectedEvent = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    // iphone with nav controller
    
    if ([[segue identifier] isEqualToString:@"showDetailiPhone"]) {
       
        NSString *webPage = [NSString stringWithFormat:@"<html><STYLE TYPE=\"text/css\"><!-- BODY {font-family:\"Helvetica Neue\"; font-size:32px;margin-top:0px;margin-right:5px;margin-left:5px} img{padding:18px;padding-left:0px;padding-top:5px;}.headlineTextBox {background:#AAAAAA;padding-bottom:2px;padding-left:5px;margin-bottom:5px;margin-left:-5px;margin-right:-5px;font-size:32px;font-weight:bold;} --></STYLE><body><div class=\"headlineTextBox\">%@</div>%@</body></html>",[selectedEvent.title capitalizedString] , selectedEvent.storyHTML];
        
        [[segue destinationViewController] setDetailItem:webPage];
    }

    if ([[segue identifier] isEqualToString:@"showTweetLinkiPhone"]) 
    {
        [[segue destinationViewController] setURLitem:selectedEvent.link];
    }

}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(RIMasterCellView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Event *event= [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (event.title)
    {
        cell.storyTitleLbl.text = [event.title capitalizedString];
    }
    if (event.storyText)
    {
        cell.storyDescLbl.text = event.storyText;
    }
    if (event.previewImagePath)
    {
        cell.articleImageView1.image = [[UIImage alloc]initWithContentsOfFile:event.previewImagePath];
    }
}

- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
