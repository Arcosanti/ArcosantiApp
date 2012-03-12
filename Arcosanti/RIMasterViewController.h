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
#import "EGORefreshTableHeaderView.h"

@class RIDetailViewController;

#import <CoreData/CoreData.h>

@interface RIMasterViewController : UITableViewController <EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>
{
    BOOL notFirstTimeLaunch;
    EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;

}

@property (strong, nonatomic) RIDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet RIMasterCellView *masterCellView;
@property (strong, nonatomic) RICoverPageViewController *coverPage;

@property (strong, nonatomic) NSPredicate *fetchedResultsPredicate;
@property (strong, nonatomic) NSMutableArray *selectedSources;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
