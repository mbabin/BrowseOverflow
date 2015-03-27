//
//  FakeURLSession.m
//  BrowseOverflow
//
//  Created by Michael Babin on 3/26/15.
//  Copyright (c) 2015 Fuzzy Aliens Ltd. All rights reserved.
//

#import "FakeURLSession.h"

@interface FakeURLSessionDataTask : NSObject
@property (nonatomic, copy) void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error);

- (void)resume;
@end

@implementation FakeURLSessionDataTask

- (void)resume {
}

@end

@interface FakeURLSession ()
@property (nonatomic) FakeURLSessionDataTask *dataTask;
@end

@implementation FakeURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
	self.dataTask = [FakeURLSessionDataTask new];
	self.dataTask.completionHandler = completionHandler;
	return (NSURLSessionDataTask *)self.dataTask;
}

- (void)didCompleteWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
	if (self.dataTask.completionHandler) {
		self.dataTask.completionHandler(data, response, error);
	}
}

@end
