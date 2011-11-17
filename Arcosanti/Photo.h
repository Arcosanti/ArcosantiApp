//
//  Photo.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/13/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * webURL;
@property (nonatomic, retain) Event *event;

@end
