//
//  RIMasterViewController.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIDetailViewController;

#import <CoreData/CoreData.h>

@interface RIMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) RIDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
