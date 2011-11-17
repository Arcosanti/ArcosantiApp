//
//  RIMasterViewController.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIMasterCellView.h"
#import "RICoverPageViewController.h"

@class RIDetailViewController;

#import <CoreData/CoreData.h>

@interface RIMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    BOOL notFirstTimeLaunch;
}

@property (strong, nonatomic) RIDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet RIMasterCellView *masterCellView;
@property (strong, nonatomic) RICoverPageViewController *coverPage;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
