//
//  RIAppDelegate.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIArcosantiFeedDelegate.h"
#import "RIArcoTwitterDelegate.h"

@interface RIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,strong) RIArcosantiFeedDelegate *todayFeedDelegate;
@property (nonatomic,strong) RIArcoTwitterDelegate *arcoTweetDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
