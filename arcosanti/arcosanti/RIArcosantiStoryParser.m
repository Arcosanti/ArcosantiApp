//
//  RIArcosantiStoryDelegate.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "RIArcosantiStoryParser.h"
#import <CoreData/CoreData.h>
#import "RSS.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"


@interface RIArcosantiStoryParser ()

@property (nonatomic,strong) NSMutableDictionary *rssEntryToLoad;
@property (nonatomic,strong) AppDelegate *appDelegate;
@property (nonatomic,strong) NSManagedObjectContext *localManagedObjectContext;
@end



@implementation RIArcosantiStoryParser


- (id)init
{
    self = [super init];
    if (self) {
        
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

        NSPersistentStoreCoordinator *coordinator = [_appDelegate persistentStoreCoordinator];
        if (coordinator != nil) {
            _localManagedObjectContext = [[NSManagedObjectContext alloc] init];
            [_localManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        
        	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        	[nc addObserver:self  selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:_localManagedObjectContext];
        
    }
    
    return self;
}


+ (NSString *)flattenHTML:(NSString *)html {
    
    
     //   NSLog(@"html: %@",html);
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL]; 
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text];
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
        
    } // while //
    
    return [NSString stringWithString:html];
}


-(void) parseDownloadData:(NSData *)data
{
    //   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    //[parser setShouldResolveExternalEntities:YES];
    [parser parse];
    
}


-(void) insertNewEvent:(NSMutableDictionary *)newEvent
{
 //  NSLog(@"loading newevent: %@",newEvent);
    NSString *dateString = [newEvent objectForKey:@"pubDate"];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];

    [dateFormat setDateFormat:@"EEE, d LLL yyyy HH:mm:ss ZZZ"];
    NSDate *eventDate = [dateFormat dateFromString:dateString];

    //RSS *existingEvent = [self fetchEventForTimeStamp:eventDate];

   // if (!(existingEvent))
   // {


        //use bit.ly to shorten link for tweeting
//        NSString *bitlyLinkText = [NSString stringWithFormat:@"http://api.bitly.com/v3/shorten?login=spacetrucker&apiKey=R_9a10371c7a346374f8e37fd884a7d6e6&longUrl=%@&format=json",[newEvent objectForKey:@"link"]];
//        NSURL *bitlyURL = [NSURL URLWithString:bitlyLinkText];
//        NSData *bitlyResponseData = [NSData dataWithContentsOfURL:bitlyURL];
//        NSDictionary *bitlyResponseDict = [NSJSONSerialization JSONObjectWithData:bitlyResponseData  options:0 error:nil];
//        NSDictionary *bitlyDataDict = [NSDictionary dictionaryWithDictionary:[bitlyResponseDict objectForKey:@"data"]];


        RSS *eventToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"RSS" inManagedObjectContext:_localManagedObjectContext];
        eventToInsert.articleTitle = [newEvent objectForKey:@"title"];
        NSString *htmlString = [newEvent objectForKey:@"description"];
    
        eventToInsert.articleDescription = [[htmlString stringByConvertingHTMLToPlainText]stringByRemovingNewLinesAndWhitespace];
        NSLog(@"Decoded: %@",eventToInsert.articleDescription);
    
        eventToInsert.articleUrl = [newEvent objectForKey:@"link"];
        eventToInsert.articleCategory = [newEvent objectForKey:@"category"];
        eventToInsert.articleDate = eventDate;
    
    
        NSString *imageURL = [self findImageTagInHTML:[newEvent objectForKey:@"description"]];
    
        NSLog(@"imageURL:%@ ",imageURL);
    
        eventToInsert.articleImage = imageURL;
    
    
        // eventToInsert.source = @"today";

       // NSLog(@"entitytoinsert: %@",entityToInsert);

        //NSString *story = [newEvent objectForKey:@"description"];
        ///RIArcosantiStoryParser *storyParser = [[RIArcosantiStoryParser alloc]init];
        
        //[storyParser loadWithStoryString:story];
        //NSString *previewPhoto = [storyParser.photos objectAtIndex:0];
        //NSString *previewPhotoFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[previewPhoto lastPathComponent]]];
        //NSString *previewPhotoFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",previewPhoto]];
        ///eventToInsert.previewImagePath = previewPhotoFilePath;
        //eventToInsert.storyText = storyParser.cleanText;

        //NSLog(@"clean text: %@",storyParser.cleanText);

//        NSFileManager *manager = [NSFileManager defaultManager];
//        BOOL directoryExists = [manager changeCurrentDirectoryPath:[NSString stringWithFormat:@"Documents/%@",[previewPhoto stringByDeletingLastPathComponent]]];
//
//        if (!(directoryExists))
//            {
//                NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[previewPhoto stringByDeletingLastPathComponent]]];
//                [manager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
//            }
//
//        for (NSString *imgURL in storyParser.photos)
//        {
//            //NSString *jpegFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[imgURL lastPathComponent]]];
//            NSString *jpegFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",imgURL]];
//            NSLog(@"saving file: %@",jpegFilePath);
//            NSURL *wwwArco = [NSURL URLWithString:@"http://www.arcosanti.org/"];
//            NSData *downloadData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL relativeToURL:wwwArco]];
//            UIImage *downloadImage = [[UIImage alloc] initWithData:downloadData];
//            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(downloadImage, 0.8f)];//1.0f = 100% quality
//            [imageData writeToFile:jpegFilePath atomically:YES];
//
//            //add photo to core data
//            Photo *photoToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_managedObjectContext];
//            photoToInsert.localPath = jpegFilePath;
//            NSLog(@"storing localPath: %@", jpegFilePath);
//            photoToInsert.webURL = imgURL;
//            [eventToInsert addPhotoObject:photoToInsert];
//        }
//

    [eventToInsert.managedObjectContext save:nil];
  //  }
 //   [[NSNotificationCenter defaultCenter] postNotificationName:nRIArcoFeedDownloadComplete object:nil];

}

-(void)mergeChanges:(NSNotification * )notification
{
    NSManagedObjectContext *mainContext = _appDelegate.managedObjectContext;
    
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];
    
    //notifiy main thread if needed
//    dispatch_async(dispatch_get_main_queue(),
//                   ^{
//                       [[NSNotificationCenter defaultCenter] postNotificationName:@"ImportLesson" object:self userInfo:userInfoDict];
//                   });
    
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Parser Delegate methods
//the start of an element
//Any attribute data is accessed here
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    elementContentString = [[NSMutableString alloc] init];
    
    if ([elementName isEqualToString:@"item"]) {
        NSLog(@"Starting item: %@", elementContentString);
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
    NSLog(@"Found Element: %@", elementName);
    if (item)
    {
        if ([elementName isEqualToString:@"title"]) {
            NSLog(@"Title: %@", elementContentString);
            [self.rssEntryToLoad setObject:elementContentString forKey:@"title"];
        }
        
        if ([elementName isEqualToString:@"link"]) {
            NSLog(@"Link: %@", elementContentString);
            [self.rssEntryToLoad setObject:elementContentString forKey:@"link"];
        }
        
        if ([elementName isEqualToString:@"description"]) {
          //   NSLog(@"Decription HTML: %@", elementContentString);
            [self.rssEntryToLoad setObject:elementContentString forKey:@"description"];
        }
        
        if ([elementName isEqualToString:@"category"]) {
             NSLog(@"Category: %@", elementContentString);
            [self.rssEntryToLoad setObject:elementContentString forKey:@"category"];
        }
        
        if ([elementName isEqualToString:@"pubDate"]) {
             NSLog(@"Pub Date: %@", elementContentString);
            [self.rssEntryToLoad setObject:elementContentString forKey:@"pubDate"];
        }
        //end at item
        
        if ([elementName isEqualToString:@"item"]) {
            
           // NSLog(@"Finished item: %@", _rssEntryToLoad);
            if (_rssEntryToLoad)
            {
                [self insertNewEvent:self.rssEntryToLoad];
            }
            self.rssEntryToLoad = nil;
            self.rssEntryToLoad = [[NSMutableDictionary alloc]init];
        }
    }
    elementContentString  = nil;
}

- (NSString *)findImageTagInHTML:(NSString *)html {
    
   // NSLog(@"html: %@",html);
    
    NSScanner *theScanner;
    NSString *text = nil;
    NSMutableArray *images = [[NSMutableArray alloc]initWithCapacity:100];
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<img" intoString:nil]; 
        
        // find end of tag
        [theScanner scanUpToString:@".preview" intoString:&text];
        
        NSString *imgSrc = nil;
       // NSString *imgURL = nil;
        NSScanner *srcScanner = [NSScanner scannerWithString:text];
       
        while ([srcScanner isAtEnd] == NO) {
         
            [srcScanner scanUpToString:@"src=\"" intoString:nil];
            [srcScanner scanUpToString:@" \"" intoString:&imgSrc];
            NSString *imgURL = [imgSrc stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"src=\""]  withString:@" "];
            imgURL = [imgURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                  
            NSLog(@"image url: %@",imgURL);
            
            if (!([images containsObject:imgURL]))
            {
                return [NSString stringWithFormat:@"%@.jpg",imgURL];
            }
        }
    } // while //
    
  //  NSArray *returnImages = [[NSArray alloc]initWithArray:images copyItems:YES];

    return @"No Image";
}





@end
