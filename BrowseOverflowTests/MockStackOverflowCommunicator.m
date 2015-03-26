//
//  MockStackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 17/03/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "MockStackOverflowCommunicator.h"

@interface StackOverflowCommunicator ()
- (instancetype)initWithDelegate:(id <StackOverflowCommunicatorDelegate>)delegate NS_DESIGNATED_INITIALIZER;
@end

@implementation MockStackOverflowCommunicator
{
    BOOL wasAskedToFetchQuestions;
    BOOL wasAskedToFetchBody;
    NSInteger questionID;
}

- (id)initWithDelegate:(id<StackOverflowCommunicatorDelegate>)delegate {
	self = [super initWithDelegate:delegate];
    if (self) {
        questionID = NSNotFound;
    }
    return self;
}

- (void)searchForQuestionsWithTag:(NSString *)tag {
    wasAskedToFetchQuestions = YES;
}

- (void)downloadInformationForQuestionWithID:(NSInteger)identifier {
    wasAskedToFetchBody = YES;
}

- (void)downloadAnswersToQuestionWithID:(NSInteger)identifier {
    questionID = identifier;
}

- (BOOL)wasAskedToFetchQuestions {
    return wasAskedToFetchQuestions;
}

- (BOOL)wasAskedToFetchBody {
    return wasAskedToFetchBody;
}

- (NSInteger)askedForAnswersToQuestionID {
    return questionID;
}

@end
