//
//  RIArcoTwitterDelegate.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/16/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIArcoTwitterDelegate.h"
#import "RIAppDelegate.h"
#import "SBJson.h"
#import "Event.h"

@implementation RIArcoTwitterDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize requestData = _requestData;
@synthesize tweets = _tweets;
@synthesize twitterFeedDict = _twitterFeedDict;


-(void) getLatestTweets
{
    //create our own MOC as this will be run in a thread
    
    RIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    /*
     NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
     
     if (coordinator != nil) {
     self.loadXMLManagedObjectContext = [[NSManagedObjectContext alloc] init];
     [_loadXMLManagedObjectContext setPersistentStoreCoordinator: coordinator];
     }
     */
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    //self.eventToLoad = [[NSMutableDictionary alloc]init];
    
    //add an observer for to merge contexts
    // Register context with the notification center
    // once the update completes we need to update the appdelegates MOC
    /*
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	[nc addObserver:self
           selector:@selector(mergeChanges:) 
               name:NSManagedObjectContextDidSaveNotification
             object:_managedObjectContext];
    */
    NSLog(@"Downloading Twitter Feed");
    
    NSURL *url = [[NSURL alloc]initWithString:@"http://search.twitter.com/search.json?q=from:arcosanti"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:req delegate:self];
	if (conn) {
		self.requestData = [NSMutableData data];		
	}
    
    
}

- (NSString *)findURLinString:(NSString *)text {
    
    NSScanner *theScanner;
    NSString *url = nil;
    
    
    theScanner = [NSScanner scannerWithString:text];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"http:" intoString:NULL]; 
        
        // find end of tag
        [theScanner scanUpToString:@" " intoString:&url];
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        //html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text]
          //                                     withString:@" "];
        
    } // while //
    
    return [NSString stringWithString:url];
}

/*
 Get a specific entity by timestap
 
 refactor in the future to a common class for tweets and today@arcosanti
 */ 
-(Event *) fetchEventForTimeStamp:(NSDate *)eventTimestamp
{	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init]; 
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext]];
    
    NSDate *earlyDate = [eventTimestamp dateByAddingTimeInterval:-1];
    NSDate *laterDate = [eventTimestamp dateByAddingTimeInterval:1];
    
    //NSLog(@"Event date: %@ between imeStamps : %@", eventTimestamp, timestamps);
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"((timeStamp >= %@) AND (timeStamp <= %@))", earlyDate,laterDate];
	[fetchRequest setPredicate:pre];
    
	NSError *error = nil;
	NSArray *fetchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if ([fetchResults count] > 0) {
		Event *eventEntity = [fetchResults objectAtIndex:0];
		return eventEntity;
	}
	else {
		return nil;
	}
}
- (void)saveManagedObjectContext  
{    
    
    NSError *error = [[NSError alloc]init];
    /*
     if (_managedObjectContext != nil) {
     if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
     
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     //abort();
     } 
     }
     */
    
    [self.managedObjectContext save:&error];
    
	NSLog(@"RIArcosantiFeedDelegate.saveManagedObjectContext: Database Saved");
    
}
- (void)insertTweetToDBFromDict:(NSDictionary *)tweetDict
{
    NSString *dateString = [tweetDict objectForKey:@"created_at"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [dateFormat setDateFormat:@"EEE, d LLL yyyy HH:mm:ss ZZZ"];
    NSDate *tweetDate = [dateFormat dateFromString:dateString];
    NSLog(@"tweetDate: %@",tweetDate);
    NSString *tweetURL = [self findURLinString:[tweetDict objectForKey:@"text"]];
    NSLog(@"url: %@",tweetURL);
    
    Event *existingEvent = [self fetchEventForTimeStamp:tweetDate];
    
    if (!(existingEvent))
    {
        Event *eventToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
        
        eventToInsert.title = @"twitter";
        eventToInsert.storyHTML = [tweetDict objectForKey:@"text"];
        eventToInsert.storyText = [tweetDict objectForKey:@"text"];
        eventToInsert.link = tweetURL;
        eventToInsert.category = @"twitter";
        eventToInsert.timeStamp = tweetDate;
        eventToInsert.source = @"arcoTwitter";
        
        
        [self saveManagedObjectContext];
    }
    
    
    
}

- (void)loadFeed
{
    NSString *requestString = [[NSString alloc] initWithData:_requestData
                                             encoding:NSUTF8StringEncoding]; 
    
    self.twitterFeedDict = [requestString JSONValue];
    
    self.tweets = [[NSArray alloc]initWithArray:[_twitterFeedDict objectForKey:@"results"]];
    
    // NSLog(@"tweets : %@",_tweets);
    
     for (NSDictionary *tweetDict in _tweets)
     {
         [self insertTweetToDBFromDict:tweetDict];
     }
    
    
    
    
}
//URL Connection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	[_requestData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[_requestData appendData:data];        
}
-(void) connection:(NSURLConnection *) connection  didFailWithError:(NSError *) error 
{
	NSLog(@"a download error occured: %@",error);
}

// handle authenticated connections if needed
/*
 - (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
 {
 NSLog(@"security challenge for productDB.xml");
 
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 
 NSURLCredential *myCreds = [NSURLCredential credentialWithUser:[defaults objectForKey:@"ad_login"]
 password:[defaults objectForKey:@"ad_password"]
 persistence:NSURLCredentialPersistenceNone];
 
 [[challenge sender] useCredential:myCreds forAuthenticationChallenge:challenge];
 }
 */

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSLog(@"Downloaded XML: %i bytes",[_requestData length]);
	//NSLog(@"feed: %@",fileData);
    
	[self loadFeed];
}
// end URL connection delegate methods




- (void)mergeChanges:(NSNotification *)notification
{
    RIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *mainContext = appDelegate.managedObjectContext;
	
	// Merge changes into the main context on the main thread
	[mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                                  withObject:notification
                               waitUntilDone:YES];	
}
@end
