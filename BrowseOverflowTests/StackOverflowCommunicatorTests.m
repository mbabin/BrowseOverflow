//
//  StackOverflowCommunicatorTests.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 11/05/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "StackOverflowCommunicatorTests.h"
#import "InspectableStackOverflowCommunicator.h"
#import "NonNetworkedStackOverflowCommunicator.h"
#import "MockStackOverflowManager.h"
#import "FakeURLResponse.h"

@interface StackOverflowCommunicator ()
@property (nonatomic) NSMutableData *receivedData;
@end

@implementation StackOverflowCommunicatorTests

- (void)setUp {
    communicator = [InspectableStackOverflowCommunicator communicatorWithDelegate:nil];
	manager = [[MockStackOverflowManager alloc] init];
    nnCommunicator = [NonNetworkedStackOverflowCommunicator communicatorWithDelegate:manager];
    fourOhFourResponse = [[FakeURLResponse alloc] initWithStatusCode: 404];
    receivedData = [[@"Result" dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
}

- (void)tearDown {
    [communicator cancelLastRequest];
}

- (void)testSearchingForQuestionsOnTopicCallsTopicAPI {
    [communicator searchForQuestionsWithTag: @"ios"];
    XCTAssertEqualObjects([[communicator URLToFetch] absoluteString], @"https://api.stackexchange.com/2.2/search?pagesize=20&order=desc&sort=activity&tagged=ios&site=stackoverflow", @"Use the search API to find questions with a particular tag");
}

- (void)testFillingInQuestionBodyCallsQuestionAPI {
    [communicator downloadInformationForQuestionWithID: 12345];
    XCTAssertEqualObjects([[communicator URLToFetch] absoluteString], @"https://api.stackexchange.com/2.2/questions/12345?order=desc&sort=activity&site=stackoverflow&filter=withbody", @"Use the question API to get the body for a question");
}

- (void)testFetchingAnswersToQuestionCallsQuestionAPI {
    [communicator downloadAnswersToQuestionWithID: 12345];
    XCTAssertEqualObjects([[communicator URLToFetch] absoluteString], @"https://api.stackexchange.com/2.2/questions/12345/answers?order=desc&sort=activity&site=stackoverflow&filter=withbody", @"Use the question API to get answers on a given question");
}

- (void)testSearchingForQuestionsCreatesURLConnection {
    [communicator searchForQuestionsWithTag: @"ios"];
    XCTAssertNotNil([communicator currentTask], @"There should be a URL data task in-flight now.");
}

- (void)testStartingNewSearchThrowsOutOldConnection {
    [communicator searchForQuestionsWithTag: @"ios"];
    NSURLSessionDataTask *firstTask = [communicator currentTask];
    [communicator searchForQuestionsWithTag: @"cocoa"];
    XCTAssertFalse([[communicator currentTask] isEqual: firstTask], @"The communicator needs to replace its data task to start a new one");
}

- (void)testReceivingResponseDiscardsExistingData {
    nnCommunicator.receivedData = [[@"Hello" dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    [nnCommunicator searchForQuestionsWithTag: @"ios"];
	[nnCommunicator URLSession:nil dataTask:nil didReceiveResponse:nil completionHandler:nil];
    XCTAssertEqual([nnCommunicator.receivedData length], (NSUInteger)0, @"Data should have been discarded");
}

- (void)testReceivingResponseWith404StatusPassesErrorToDelegate {
    [nnCommunicator searchForQuestionsWithTag: @"ios"];
	[nnCommunicator URLSession:nil dataTask:nil didReceiveResponse:(NSURLResponse *)fourOhFourResponse completionHandler:nil];
    XCTAssertEqual([manager topicFailureErrorCode], 404, @"Fetch failure was passed through to delegate");
}

- (void)testNoErrorReceivedOn200Status {
    FakeURLResponse *twoHundredResponse = [[FakeURLResponse alloc] initWithStatusCode: 200];
    [nnCommunicator searchForQuestionsWithTag: @"ios"];
	[nnCommunicator URLSession:nil dataTask:nil didReceiveResponse:(NSURLResponse *)twoHundredResponse completionHandler:nil];
    XCTAssertFalse([manager topicFailureErrorCode] == 200, @"No need for error on 200 response");
}

- (void)testReceiving404ResponseToQuestionBodyRequestPassesErrorToDelegate {
    [nnCommunicator downloadInformationForQuestionWithID: 12345];
	[nnCommunicator URLSession:nil dataTask:nil didReceiveResponse:(NSURLResponse *)fourOhFourResponse completionHandler:nil];
    XCTAssertEqual([manager bodyFailureErrorCode], 404, @"Body fetch error was passed through to delegate");
}

- (void)testReceiving404ResponseToAnswerRequestPassesErrorToDelegate {
    [nnCommunicator downloadAnswersToQuestionWithID: 12345];
	[nnCommunicator URLSession:nil dataTask:nil didReceiveResponse:(NSURLResponse *)fourOhFourResponse completionHandler:nil];
    XCTAssertEqual([manager answerFailureErrorCode], 404, @"Answer fetch error was passed to delegate");
}

- (void)testConnectionFailingPassesErrorToDelegate {
    [nnCommunicator searchForQuestionsWithTag: @"ios"];
    NSError *error = [NSError errorWithDomain: @"Fake domain" code: 12345 userInfo: nil];
	[nnCommunicator URLSession:nil task:nil didCompleteWithError:error];
    XCTAssertEqual([manager topicFailureErrorCode], 12345, @"Failure to connect should get passed to the delegate");
}

- (void)testSuccessfulQuestionSearchPassesDataToDelegate {
    [nnCommunicator searchForQuestionsWithTag: @"ios"];
    [nnCommunicator setReceivedData: receivedData];
	[nnCommunicator URLSession:nil task:nil didCompleteWithError:nil];
    XCTAssertEqualObjects([manager topicSearchString], @"Result", @"The delegate should have received data on success");
}

- (void)testSuccessfulBodyFetchPassesDataToDelegate {
    [nnCommunicator downloadInformationForQuestionWithID: 12345];
    [nnCommunicator setReceivedData: receivedData];
	[nnCommunicator URLSession:nil task:nil didCompleteWithError:nil];
    XCTAssertEqualObjects([manager questionBodyString], @"Result", @"The delegate should have received the question body data");
}

- (void)testSuccessfulAnswerFetchPassesDataToDelegate {
    [nnCommunicator downloadAnswersToQuestionWithID: 12345];
    [nnCommunicator setReceivedData: receivedData];
	[nnCommunicator URLSession:nil task:nil didCompleteWithError:nil];
    XCTAssertEqualObjects([manager answerListString], @"Result", @"Answer list should be passed to delegate");
}

- (void)testAdditionalDataAppendedToDownload {
    [nnCommunicator setReceivedData: receivedData];
    NSData *extraData = [@" appended" dataUsingEncoding: NSUTF8StringEncoding];
	[nnCommunicator URLSession:nil dataTask:nil didReceiveData:extraData];
    NSString *combinedString = [[NSString alloc] initWithData: [nnCommunicator receivedData] encoding: NSUTF8StringEncoding];
    XCTAssertEqualObjects(combinedString, @"Result appended", @"Received data should be appended to the downloaded data");
}

@end
