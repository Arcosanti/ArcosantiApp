//
//  RIArcosantiTagTwitterDelegate.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 2/1/12.
//  Copyright (c) 2012 river.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIArcosantiTagTwitterDelegate : NSObject

@property (nonatomic,strong) NSMutableData *requestData;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSArray *tweets;
@property (nonatomic,strong) NSDictionary *twitterFeedDict;

-(void)getLatestTweets;

@end
