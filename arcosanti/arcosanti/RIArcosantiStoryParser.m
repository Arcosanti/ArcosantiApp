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

+ (NSString *)flattenHTML:(NSString *)html
{

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
    parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}


-(void) insertNewEvent:(NSMutableDictionary *)newEvent
{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

        NSString *dateString = [newEvent objectForKey:@"pubDate"];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];

        [dateFormat setDateFormat:@"EEE, d LLL yyyy HH:mm:ss ZZZ"];
        NSDate *eventDate = [dateFormat dateFromString:dateString];

        RSS *eventToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"RSS" inManagedObjectContext:self.appDelegate.managedObjectContext];
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


        [eventToInsert.managedObjectContext save:nil];
        
    });

}

- (void)dealloc
{
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
