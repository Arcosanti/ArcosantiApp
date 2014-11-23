//
//  RSS.h
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/22/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RSS : NSManagedObject

@property (nonatomic, retain) NSDate * articleDate;
@property (nonatomic, retain) NSString * articleTitle;
@property (nonatomic, retain) NSString * articleUrl;
@property (nonatomic, retain) NSString * articleCategory;
@property (nonatomic, retain) NSString * articleDescription;
@property (nonatomic, retain) NSString * articleImage;

@end
