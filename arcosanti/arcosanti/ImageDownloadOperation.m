//
//  ImageDownloadOperation.m
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/22/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ImageDownloadOperation.h"

@interface ImageDownloadOperation ()

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, weak)   NSURLConnection *imageConnection;
@property (assign) BOOL isExecuting;
@property (assign)  BOOL isFinished;
@property (nonatomic, strong) UIImage *downloadImage;

@end

@implementation ImageDownloadOperation

-(void)start
{
    if (self.isCancelled)
    {
        self.isExecuting = NO;
        self.isFinished = YES;
        return;
    };
    
    self.isExecuting = YES;
    self.isFinished = NO;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageUrlString]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    
   // self.imageConnection = connection;
}

#pragma mark NSOperation Specific Methods

- (BOOL)isConcurrent
{
    return YES;
}
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return YES;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.activeDownload = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    self.downloadImage = [[UIImage alloc] initWithData:self.activeDownload];
    
    [self saveFileForImage:self.downloadImage forUrlString:self.imageUrlString];


}

-(void)updateImage
{
    if (self.tableCell)
    {
        [_tableCell updateImageForImage:[self.downloadImage copy]];
    }
    

}

-(void)saveFileForImage:(UIImage *)saveImage forUrlString:(NSString *)imgURL
{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *jpegFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",[imgURL lastPathComponent]]];
    
    
    BOOL fileExists = [manager fileExistsAtPath:jpegFilePath];
    
    if (!(fileExists))
    {
        NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(self.downloadImage, 1.0f)];//1.0f = 100% quality
        [imageData writeToFile:jpegFilePath atomically:YES];
    }
    
    [self performSelectorOnMainThread:@selector(updateImage) withObject:nil waitUntilDone:YES];
    
    self.isExecuting = NO;
    self.isFinished = YES;
}



@end
