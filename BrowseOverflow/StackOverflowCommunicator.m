//
//  StackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 17/03/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "StackOverflowCommunicator.h"

@interface StackOverflowCommunicator ()

@property (nonatomic) NSURL *fetchingURL;
@property (nonatomic) NSURLConnection *fetchingConnection;
@property (nonatomic) NSMutableData *receivedData;
@property (nonatomic,copy) void (^errorHandler)(NSError *);
@property (nonatomic,copy) void (^successHandler)(NSString *);

@end

@implementation StackOverflowCommunicator

@synthesize delegate;

- (void)launchConnectionForRequest: (NSURLRequest *)request  {
  [self cancelAndDiscardURLConnection];
    self.fetchingConnection = [NSURLConnection connectionWithRequest: request delegate: self];

}
- (void)fetchContentAtURL:(NSURL *)url errorHandler:(void (^)(NSError *))errorBlock successHandler:(void (^)(NSString *))successBlock {
    self.fetchingURL = url;
    self.errorHandler = [errorBlock copy];
    self.successHandler = [successBlock copy];
    NSURLRequest *request = [NSURLRequest requestWithURL: self.fetchingURL];
    
    [self launchConnectionForRequest: request];

    
}

- (void)searchForQuestionsWithTag:(NSString *)tag {
	[self fetchContentAtURL: [NSURL URLWithString:
							  [NSString stringWithFormat: @"https://api.stackexchange.com/2.2/search?pagesize=20&order=desc&sort=activity&tagged=%@&site=stackoverflow", tag]]
               errorHandler: ^(NSError *error) {
                   [delegate searchingForQuestionsFailedWithError: error];
               }
             successHandler: ^(NSString *objectNotation) {
                 [delegate receivedQuestionsJSON: objectNotation];
             }];
}

- (void)downloadInformationForQuestionWithID:(NSInteger)identifier {
    [self fetchContentAtURL: [NSURL URLWithString:
							  [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%ld?order=desc&sort=activity&site=stackoverflow&filter=withbody", (long)identifier]]
               errorHandler: ^(NSError *error) {
                   [delegate fetchingQuestionBodyFailedWithError: error];
               }
             successHandler: ^(NSString *objectNotation) {
                 [delegate receivedQuestionBodyJSON: objectNotation];
             }];
}

- (void)downloadAnswersToQuestionWithID:(NSInteger)identifier {
    [self fetchContentAtURL: [NSURL URLWithString:
							  [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%ld/answers?order=desc&sort=activity&site=stackoverflow&filter=withbody", (long)identifier]]
               errorHandler: ^(NSError *error) {
                   [delegate fetchingAnswersFailedWithError: error];
               }
             successHandler: ^(NSString *objectNotation) {
                 [delegate receivedAnswerListJSON: objectNotation];
             }];
}

- (void)dealloc {
    [self.fetchingConnection cancel];
}

- (void)cancelAndDiscardURLConnection {
    [self.fetchingConnection cancel];
    self.fetchingConnection = nil;
}

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.receivedData = nil;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] != 200) {
        NSError *error = [NSError errorWithDomain: StackOverflowCommunicatorErrorDomain code: [httpResponse statusCode] userInfo: nil];
        self.errorHandler(error);
        [self cancelAndDiscardURLConnection];
    }
    else {
        self.receivedData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    self.fetchingConnection = nil;
    self.fetchingURL = nil;
    self.errorHandler(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.fetchingConnection = nil;
    self.fetchingURL = nil;
    NSString *receivedText = [[NSString alloc] initWithData: self.receivedData
                                                   encoding: NSUTF8StringEncoding];
    self.receivedData = nil;
    self.successHandler(receivedText);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData: data];
}

@end

NSString *StackOverflowCommunicatorErrorDomain = @"StackOverflowCommunicatorErrorDomain";
