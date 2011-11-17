//
//  RIArcoTwitterDelegate.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/16/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//
// http://search.twitter.com/search.json?q=from:arcosanti

#import <Foundation/Foundation.h>

@interface RIArcoTwitterDelegate : NSObject <NSURLConnectionDelegate>

@property (nonatomic,strong) NSMutableData *requestData;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSArray *tweets;
@property (nonatomic,strong) NSDictionary *twitterFeedDict;

-(void)getLatestTweets;


@end
