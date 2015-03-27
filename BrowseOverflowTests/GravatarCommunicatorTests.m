//
//  GravatarCommunicatorTests.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 26/05/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "GravatarCommunicatorTests.h"
#import "GravatarCommunicator.h"
#import "FakeGravatarDelegate.h"
#import "FakeURLSession.h"

@interface GravatarCommunicator ()
@property (nonatomic) NSURLSession *session;
@end

@interface GravatarCommunicatorTests ()

@property (nonatomic) GravatarCommunicator *communicator;
@property (nonatomic) FakeGravatarDelegate *delegate;
@property (nonatomic) NSData *fakeData;
@property (nonatomic) FakeURLSession *fakeSession;
@end

@implementation GravatarCommunicatorTests

- (void)setUp {
    self.communicator = [[GravatarCommunicator alloc] init];
    self.delegate = [[FakeGravatarDelegate alloc] init];
	self.fakeSession = [FakeURLSession new];
    self.communicator.url = [NSURL URLWithString: @"http://example.com/avatar"];
    self.communicator.delegate = self.delegate;
	self.communicator.session = (NSURLSession *)self.fakeSession;
    self.fakeData = [@"Fake data" dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)tearDown {
	self.communicator = nil;
	self.delegate = nil;
	self.fakeData = nil;
	self.fakeSession = nil;
}

- (void)testThatCommunicatorPassesURLBackWhenCompleted {
	[self.communicator fetchDataForURL:self.communicator.url];
	[self.fakeSession didCompleteWithData:nil response:nil error:nil];
    XCTAssertEqualObjects([self.delegate reportedURL], self.communicator.url, @"The communicator needs to explain which URL it's downloaded content for");
}

- (void)testThatCommunicatorPassesDataWhenCompleted {
	[self.communicator fetchDataForURL:self.communicator.url];
	[self.fakeSession didCompleteWithData:self.fakeData response:nil error:nil];
    XCTAssertEqualObjects([self.delegate reportedData], self.fakeData, @"The communicator needs to pass its data to the delegate");
}

- (void)testCommunicatorKeepsURLRequested {
    NSURL *differentURL = [NSURL URLWithString: @"http://example.org/notthesameURL"];
    [self.communicator fetchDataForURL:differentURL];
    XCTAssertEqualObjects(self.communicator.url, differentURL, @"Communicator holds on to URL");
}

- (void)testURLPassedBackOnError {
	[self.communicator fetchDataForURL:self.communicator.url];
	[self.fakeSession didCompleteWithData:nil response:nil error:[NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil]];
    XCTAssertEqualObjects([self.delegate reportedURL], self.communicator.url, @"delegate knows which URL got an error");
}

@end
