//
//  FakeURLSession.h
//  BrowseOverflow
//
//  Created by Michael Babin on 3/26/15.
//  Copyright (c) 2015 Fuzzy Aliens Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeURLSession : NSObject

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (void)didCompleteWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

@end
