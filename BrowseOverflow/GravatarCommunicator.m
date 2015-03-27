//
//  GravatarCommunicator.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 26/05/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "GravatarCommunicator.h"

@interface GravatarCommunicator ()
@property (nonatomic) NSURLSession *session;
@end

@implementation GravatarCommunicator

- (instancetype)init {
	self = [super init];
	if (self) {
		_session = [NSURLSession sharedSession];
	}
	return self;
}

- (void)fetchDataForURL:(NSURL *)location {
    self.url = location;
	__weak typeof(self) weakSelf = self;
	NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:location completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
		typeof(self) strongSelf = weakSelf;
		if (error) {
			[strongSelf.delegate communicatorGotErrorForURL:strongSelf.url];
		} else {
			[strongSelf.delegate communicatorReceivedData:data forURL:strongSelf.url];
		}
	}];
	[dataTask resume];
}

@end
