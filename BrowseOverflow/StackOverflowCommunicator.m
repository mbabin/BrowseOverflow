//
//  StackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 17/03/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "StackOverflowCommunicator.h"

@interface StackOverflowCommunicator ()

- (instancetype)initWithDelegate:(id <StackOverflowCommunicatorDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURL *fetchingURL;
@property (nonatomic) NSURLSessionDataTask *fetchingDataTask;
@property (nonatomic) NSMutableData *receivedData;
@property (nonatomic,copy) void (^errorHandler)(NSError *);
@property (nonatomic,copy) void (^successHandler)(NSString *);

@end

@implementation StackOverflowCommunicator

+ (instancetype)communicatorWithDelegate:(id <StackOverflowCommunicatorDelegate>)delegate {
	StackOverflowCommunicator *communicator = [[self alloc] initWithDelegate:delegate];
	communicator.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:communicator delegateQueue:[NSOperationQueue mainQueue]];
	return communicator;
}

- (instancetype)initWithDelegate:(id <StackOverflowCommunicatorDelegate>)delegate {
	self = [super init];
	if (self) {
		_delegate = delegate;
	}
	return self;
}

- (instancetype)init {
	return [self initWithDelegate:nil];
}

- (void)launchConnectionForRequest: (NSURLRequest *)request  {
	[self cancelLastRequest];
	self.fetchingDataTask = [self.session dataTaskWithRequest:request];
	[self.fetchingDataTask resume];
}

- (void)fetchContentAtURL:(NSURL *)url errorHandler:(void (^)(NSError *))errorBlock successHandler:(void (^)(NSString *))successBlock {
    self.fetchingURL = url;
    self.errorHandler = errorBlock;
    self.successHandler = successBlock;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.fetchingURL];
    
    [self launchConnectionForRequest:request];
}

- (void)searchForQuestionsWithTag:(NSString *)tag {
	[self fetchContentAtURL: [NSURL URLWithString:
							  [NSString stringWithFormat: @"https://api.stackexchange.com/2.2/search?pagesize=20&order=desc&sort=activity&tagged=%@&site=stackoverflow", tag]]
               errorHandler: ^(NSError *error) {
                   [self.delegate searchingForQuestionsFailedWithError: error];
               }
             successHandler: ^(NSString *objectNotation) {
                 [self.delegate receivedQuestionsJSON: objectNotation];
             }];
}

- (void)downloadInformationForQuestionWithID:(NSInteger)identifier {
    [self fetchContentAtURL: [NSURL URLWithString:
							  [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%ld?order=desc&sort=activity&site=stackoverflow&filter=withbody", (long)identifier]]
               errorHandler: ^(NSError *error) {
                   [self.delegate fetchingQuestionBodyFailedWithError: error];
               }
             successHandler: ^(NSString *objectNotation) {
                 [self.delegate receivedQuestionBodyJSON: objectNotation];
             }];
}

- (void)downloadAnswersToQuestionWithID:(NSInteger)identifier {
    [self fetchContentAtURL: [NSURL URLWithString:
							  [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%ld/answers?order=desc&sort=activity&site=stackoverflow&filter=withbody", (long)identifier]]
               errorHandler: ^(NSError *error) {
                   [self.delegate fetchingAnswersFailedWithError: error];
               }
             successHandler: ^(NSString *objectNotation) {
                 [self.delegate receivedAnswerListJSON: objectNotation];
             }];
}

- (void)dealloc {
    [self.fetchingDataTask cancel];
}

- (void)cancelLastRequest {
    [self.fetchingDataTask cancel];
    self.fetchingDataTask = nil;
}

#pragma mark NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
	self.receivedData = nil;
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	if ([httpResponse statusCode] != 200) {
		NSError *error = [NSError errorWithDomain: StackOverflowCommunicatorErrorDomain code: [httpResponse statusCode] userInfo: nil];
		self.errorHandler(error);
		if (completionHandler) {
			completionHandler(NSURLSessionResponseCancel);
			self.fetchingDataTask = nil;
		} else {
			[self cancelLastRequest];
		}
	}
	else {
		self.receivedData = [[NSMutableData alloc] init];
		if (completionHandler) {
			completionHandler(NSURLSessionResponseAllow);
		}
	}
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
	[self.receivedData appendData:data];
}

#pragma mark NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	self.fetchingDataTask = nil;
	self.fetchingURL = nil;
	if (error) {
		self.receivedData = nil;
		self.errorHandler(error);
	} else {
		NSString *receivedText = [[NSString alloc] initWithData:self.receivedData
													   encoding:NSUTF8StringEncoding];
		self.receivedData = nil;
		self.successHandler(receivedText);
	}
}

@end

NSString *StackOverflowCommunicatorErrorDomain = @"StackOverflowCommunicatorErrorDomain";
