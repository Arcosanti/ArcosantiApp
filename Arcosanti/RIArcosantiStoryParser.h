//
//  RIArcosantiStoryDelegate.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIArcosantiStoryParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *parser;
    NSMutableString *elementContentString;
    BOOL item;
}

@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) NSString *cleanText;

-(void) loadWithStoryString:(NSString *)story;

@end
