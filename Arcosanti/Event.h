//
//  Event.h
//  Arcosanti
//
//  Created by Jeff Kunzelman on 11/16/11.
//  Copyright (c) 2011 river.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * previewImagePath;
@property (nonatomic, retain) NSString * storyHTML;
@property (nonatomic, retain) NSString * storyText;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSSet *photo;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

@end
