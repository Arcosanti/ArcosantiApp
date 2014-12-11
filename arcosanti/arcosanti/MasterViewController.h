//
//  MasterViewController.h
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/22/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ArcoNewsStoryViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ArcoNewsStoryViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

