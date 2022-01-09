//
//  DownloadController.h
//  Masal Zamanı
//
//  Created by Emrah Hisir on 2/21/13.
//  Copyright (c) 2013 Emrah Hisir. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOWNLOAD_FILE_NAME_DELIMETER "##"

@protocol DownloadControllerDelegate <NSObject>
@optional
- (void) didReceiveData: (NSData *) data;
- (void) didReceiveFilename: (NSString *) name;
- (void) dataDownloadFailed: (NSString *) reason;
- (void) dataDownloadAtPercent: (NSNumber *) percent;
- (void) urlNotValid: (NSString *) urlString;
@end

@interface DownloadController : NSObject<NSURLConnectionDelegate>

@property (retain) NSURLResponse *response;
@property (retain) NSURLConnection *urlconnection;
@property (retain) NSMutableData *data;
@property (retain) NSString *urlString;
@property (assign) BOOL isDownloading;
@property (nonatomic, strong) id<DownloadControllerDelegate> delegate;

+ (DownloadController *) sharedInstance;
+ (void) download:(NSString *) URLString;
+ (void) cancel;
+ (void) close;

@end