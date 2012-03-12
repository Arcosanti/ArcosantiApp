//
//  RIArcosantiStoryDelegate.m
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import "RIArcosantiStoryParser.h"

@implementation RIArcosantiStoryParser
@synthesize photos = _photos;
@synthesize cleanText = _cleanText;



- (NSString *)flattenHTML:(NSString *)html {
    
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

- (NSArray *)findImageTagsInHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    NSMutableArray *images = [[NSMutableArray alloc]initWithCapacity:100];
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<img" intoString:nil]; 
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text];
        
        NSString *imgSrc = nil;
       // NSString *imgURL = nil;
        NSScanner *srcScanner = [NSScanner scannerWithString:text];
       
        while ([srcScanner isAtEnd] == NO) {
         
            [srcScanner scanUpToString:@"src=\"" intoString:nil];
            [srcScanner scanUpToString:@" \"" intoString:&imgSrc];
            NSString *imgURL = [imgSrc stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"src=\""]  withString:@" "];
            imgURL = [imgURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                  
            //NSLog(@"image url: %@",imgURL);
            
            if (!([images containsObject:imgURL]))
            {
                [images addObject:imgURL];
            }
        }
    } // while //
    
    NSArray *returnImages = [[NSArray alloc]initWithArray:images copyItems:YES];

    return returnImages;
}

-(void) getPhotosForStory:(NSString *)story
{
    //   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    self.photos = [[NSArray alloc]initWithArray:[self findImageTagsInHTML:story]];
    
  //  NSLog(@"Found images: %@",_photos);
}

-(void) loadWithStoryString:(NSString *)story
{
    self.cleanText = [self flattenHTML:story];
    
    self.cleanText = [self.cleanText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   // self.cleanText = [self.cleanText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
   // NSLog(@"clean text: %@",_cleanText);
    
    [self getPhotosForStory:story];
}


@end
