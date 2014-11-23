//
//  ImageDownloadOperation.h
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/22/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsTableViewCell.h"

@interface ImageDownloadOperation : NSOperation

@property (nonatomic, strong) NSString *imageUrlString;
@property (readonly) BOOL isExecuting;
@property (readonly)  BOOL isFinished;

@property (nonatomic,weak) NewsTableViewCell *tableCell;

@end
