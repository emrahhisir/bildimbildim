//
//  DownloadController.m
//  Masal Zamanı
//
//  Created by Emrah Hisir on 2/21/13.
//  Copyright (c) 2013 Emrah Hisir. All rights reserved.
//

#import "DownloadController.h"

#define DELEGATE_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];
#define NUMBER(X) [NSNumber numberWithFloat:X]

@implementation DownloadController

@synthesize response=_response, data=_data, delegate=_delegate, urlString=_urlString, urlconnection=_urlconnection, isDownloading=_isDownloading;

static DownloadController *sharedInstance = nil;

- (void) start
{
    self.isDownloading = NO;
    
    NSURL *url = [NSURL URLWithString:_urlString];
    if (!url)
    {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL from string %@", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:20.0];
    if (!request)
    {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL request from string %@", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
        return;
    }
    
    self.urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    if (!self.urlconnection)
    {
        NSString *reason = [NSString stringWithFormat:@"URL connection failed for string %@", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
        return;
    }
    
    self.isDownloading = YES;
    
    // Create the new data object
    self.data = [NSMutableData data];
    self.response = nil;
    
    [self.urlconnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.urlconnection start];
}

- (void) cleanup
{
    self.data = nil;
    self.response = nil;
    self.urlconnection = nil;
    self.urlString = nil;
    self.isDownloading = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // store the response information
    self.response = response;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.response;
    NSInteger code = [httpResponse statusCode];
    if (code != 200)
    {
        DELEGATE_CALLBACK(urlNotValid:, response.URL.absoluteString);
    }
    // Check for bad connection
    /*if ([response expectedContentLength] < 0)
    {
        //NSString *reason = [NSString stringWithFormat:@"Invalid URL [%@]", self.urlString];
        DELEGATE_CALLBACK(didReceiveData:, nil);
        [connection cancel];
        [self cleanup];
    }*/
    else if ([response suggestedFilename])
    {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        NSString *fileNameByLastModified = [NSString stringWithFormat:@"%@%s%@", [response suggestedFilename],DOWNLOAD_FILE_NAME_DELIMETER, [dictionary valueForKey:@"Last-Modified"]];
        DELEGATE_CALLBACK(didReceiveFilename:, fileNameByLastModified);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    // append the new data and update the delegate
    [self.data appendData:theData];
    if (self.response)
    {
        float expectedLength = [self.response expectedContentLength];
        float currentLength = self.data.length;
        float percent = currentLength / expectedLength;
        DELEGATE_CALLBACK(dataDownloadAtPercent:, NUMBER(percent));
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // finished downloading the data, cleaning up
    self.response = nil;
    
    // Delegate is responsible for releasing data
    if (self.delegate)
    {
        NSData *theData = nil;
        DELEGATE_CALLBACK(didReceiveData:, theData);
    }
    // Cleanup is responsible for releasing data
    /*[self.urlconnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self cleanup];*/
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isDownloading = NO;
    //NSLog(@"Error: Failed connection, %@", [error localizedDescription]);
    DELEGATE_CALLBACK(dataDownloadFailed:, @"Failed Connection");
    [self cleanup];
}

+ (DownloadController *) sharedInstance
{
    if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

+ (void) download:(NSString *) URLString
{
    @synchronized(self) {
        if (sharedInstance.isDownloading)
        {
            /*NSLog(@"Error: Cannot start new download until current download finishes");
             DELEGATE_CALLBACK(dataDownloadFailed:, @"");
             return;*/
            [DownloadController close];
        }
        
        sharedInstance.urlString = URLString;
        [sharedInstance start];
    }
}

+ (void) cancel
{
    if (sharedInstance.isDownloading) [sharedInstance.urlconnection cancel];
}

+ (void)close
{
    if (sharedInstance) {
        [sharedInstance.urlconnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        if (sharedInstance.isDownloading) [sharedInstance.urlconnection cancel];
        [sharedInstance cleanup];
    }
}

@end
