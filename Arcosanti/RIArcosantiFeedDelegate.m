//
//  RIArcosantiFeedDelegate.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIArcosantiFeedDelegate.h"
#import "RIAppDelegate.h"
#import "Event.h"
#import "RIArcosantiStoryParser.h"
#import "Photo.h"

@implementation RIArcosantiFeedDelegate

@synthesize fileData;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize eventToLoad = _eventToLoad;


-(void) parseDownloadThread
{
    //   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    parser = [[NSXMLParser alloc] initWithData:fileData];	
	[parser setDelegate:self];
	//[parser setShouldResolveExternalEntities:YES];
	[parser parse];
    
}

-(void)loadDBWithDownload
{
    //get rid of old parser if it's around
	if( parser )
	{
		parser = nil;
	}	
    
    [self parseDownloadThread];
	//[NSThread detachNewThreadSelector:@selector(parseDownloadThread) toTarget:self withObject:nil];	
}


-(void) getLatestEvents
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
    self.eventToLoad = [[NSMutableDictionary alloc]init];
    
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
    
    
    NSLog(@"Downloading RSS Feed");
    
    NSURL *url = [[NSURL alloc]initWithString:@"http://www.arcosanti.org/today/rss.xml"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:req delegate:self];
	if (conn) {
		fileData = [NSMutableData data];
		
	}
    
    [self loadDBWithDownload];
}

#pragma mark - core data methods

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

-(void) insertNewEvent:(NSMutableDictionary *)newEvent
{
   //NSLog(@"loading newevent: %@",[newEvent objectForKey:@"pubDate"]); 
    NSString *dateString = [newEvent objectForKey:@"pubDate"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [dateFormat setDateFormat:@"EEE, d LLL yyyy HH:mm:ss ZZZ"];
    NSDate *eventDate = [dateFormat dateFromString:dateString];
     
    Event *existingEvent = [self fetchEventForTimeStamp:eventDate];
    
    if (!(existingEvent))
    {
        
        
        //use bit.ly to shorten link for tweeting
        NSString *bitlyLinkText = [NSString stringWithFormat:@"http://api.bitly.com/v3/shorten?login=spacetrucker&apiKey=R_9a10371c7a346374f8e37fd884a7d6e6&longUrl=%@&format=json",[newEvent objectForKey:@"link"]]; 
        NSURL *bitlyURL = [NSURL URLWithString:bitlyLinkText];                           
        NSData *bitlyResponseData = [NSData dataWithContentsOfURL:bitlyURL];        
        NSDictionary *bitlyResponseDict = [NSJSONSerialization JSONObjectWithData:bitlyResponseData  options:0 error:nil]; 
        NSDictionary *bitlyDataDict = [NSDictionary dictionaryWithDictionary:[bitlyResponseDict objectForKey:@"data"]];
        

        Event *eventToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
        eventToInsert.title = [newEvent objectForKey:@"title"];
        eventToInsert.storyHTML = [newEvent objectForKey:@"description"];
        eventToInsert.link = [bitlyDataDict objectForKey:@"url"];
        NSLog(@"ShortendLink: %@",eventToInsert.link);
        eventToInsert.category = [newEvent objectForKey:@"category"];
        eventToInsert.timeStamp = eventDate;
        eventToInsert.source = @"today";
        
       // NSLog(@"entitytoinsert: %@",entityToInsert);
        
        NSString *story = [newEvent objectForKey:@"description"];
        RIArcosantiStoryParser *storyParser = [[RIArcosantiStoryParser alloc]init];
        [storyParser loadWithStoryString:story];
        NSString *previewPhoto = [storyParser.photos objectAtIndex:0];
        //NSString *previewPhotoFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[previewPhoto lastPathComponent]]];
        NSString *previewPhotoFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",previewPhoto]];
        eventToInsert.previewImagePath = previewPhotoFilePath;
        eventToInsert.storyText = storyParser.cleanText;
        
        //NSLog(@"clean text: %@",storyParser.cleanText);
        
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL directoryExists = [manager changeCurrentDirectoryPath:[NSString stringWithFormat:@"Documents/%@",[previewPhoto stringByDeletingLastPathComponent]]];
        
        if (!(directoryExists))
            {
                NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[previewPhoto stringByDeletingLastPathComponent]]];
                [manager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        
        for (NSString *imgURL in storyParser.photos)
        {
            //NSString *jpegFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[imgURL lastPathComponent]]];
            NSString *jpegFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",imgURL]];
            NSLog(@"saving file: %@",jpegFilePath);
            NSURL *wwwArco = [NSURL URLWithString:@"http://www.arcosanti.org/"];
            NSData *downloadData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL relativeToURL:wwwArco]];
            UIImage *downloadImage = [[UIImage alloc] initWithData:downloadData];
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(downloadImage, 0.8f)];//1.0f = 100% quality
            [imageData writeToFile:jpegFilePath atomically:YES];
            
            //add photo to core data
            Photo *photoToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_managedObjectContext];
            photoToInsert.localPath = jpegFilePath;
            NSLog(@"storing localPath: %@", jpegFilePath);
            photoToInsert.webURL = imgURL;
            [eventToInsert addPhotoObject:photoToInsert];
        }
        
       [self saveManagedObjectContext];
    }   
}

- (void)mergeChanges:(NSNotification *)notification
{
	 RIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *mainContext = appDelegate.managedObjectContext;
	
	// Merge changes into the main context on the main thread
	[mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                                  withObject:notification
                               waitUntilDone:YES];	
}

// Parser Delegate methods
//the start of an element
//Any attribute data is accessed here
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    elementContentString = [[NSMutableString alloc] init];
    
    if ([elementName isEqualToString:@"item"]) {		
		//NSLog(@"Starting item: %@", elementContentString);
        item = YES;
		
	}
    
}
//This grabs the element content by character repeating till it hits the closing tag.
-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[elementContentString appendString:string];
}
//ending element
-(void) parser: (NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"Found Element: %@", elementName);
    if (item)
    {
        if ([elementName isEqualToString:@"title"]) {		
          //  NSLog(@"Title: %@", elementContentString);	
            [self.eventToLoad setObject:elementContentString forKey:@"title"];
        }
        
        if ([elementName isEqualToString:@"link"]) {		
            //NSLog(@"Link: %@", elementContentString);	
            [self.eventToLoad setObject:elementContentString forKey:@"link"];
        }
        
        if ([elementName isEqualToString:@"description"]) {		
           // NSLog(@"Decription HTML: %@", elementContentString);	
            [self.eventToLoad setObject:elementContentString forKey:@"description"];
        }
        
        if ([elementName isEqualToString:@"category"]) {		
           // NSLog(@"Category: %@", elementContentString);	
            [self.eventToLoad setObject:elementContentString forKey:@"category"];
        }
        
        if ([elementName isEqualToString:@"pubDate"]) {		
           // NSLog(@"Pub Date: %@", elementContentString);	
            [self.eventToLoad setObject:elementContentString forKey:@"pubDate"];
        }
        //end at item
        
        if ([elementName isEqualToString:@"item"]) {		
            //NSLog(@"Finished item: %@", _eventToLoad);	
            [self insertNewEvent:_eventToLoad];
            self.eventToLoad = nil;
            self.eventToLoad = [[NSMutableDictionary alloc]init];
            
        }
    }
    elementContentString  = nil;
}


//URL Connection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	[fileData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[fileData appendData:data];        
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
	NSLog(@"Downloaded XML: %i bytes",[fileData	length]);
	//NSLog(@"feed: %@",fileData);
    
	[self loadDBWithDownload];
}
// end URL connection delegate methods


@end
