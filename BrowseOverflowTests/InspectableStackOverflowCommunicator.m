//
//  InspectableStackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 11/05/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "InspectableStackOverflowCommunicator.h"

@interface StackOverflowCommunicator ()

@property (nonatomic) NSURL *fetchingURL;
@property (nonatomic) NSURLSessionDataTask *fetchingDataTask;

@end

@implementation InspectableStackOverflowCommunicator

- (NSURL *)URLToFetch {
    return self.fetchingURL;
}

- (NSURLSessionDataTask *)currentTask {
    return self.fetchingDataTask;
}


@end
