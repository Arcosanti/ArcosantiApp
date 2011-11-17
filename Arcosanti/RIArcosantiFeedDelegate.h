//
//  RIArcosantiFeedDelegate.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIArcosantiFeedDelegate : NSObject <NSXMLParserDelegate,NSURLConnectionDelegate>
{
    NSXMLParser *parser;
    NSMutableString *elementContentString;
    BOOL item;
}
@property (nonatomic,strong) NSMutableDictionary *eventToLoad;
@property (nonatomic,strong) NSMutableData *fileData;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;


-(void)getLatestEvents;


@end
