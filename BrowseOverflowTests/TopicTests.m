//
//  TopicTests.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 17/02/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "TopicTests.h"
#import "Topic.h"
#import "Question.h"

@interface TopicTests ()
@property (nonatomic) Topic *topic;
@property (nonatomic) Question *question;
@end

@implementation TopicTests

- (void)setUp {
    self.topic = [[Topic alloc] initWithName:@"iPhone" tag:@"iphone"];
	self.question = [[Question alloc] init];
	self.question.questionID = 1;
}

- (void)tearDown {
	self.topic = nil;
	self.question = nil;
}

- (void)testThatTopicExists {
    XCTAssertNotNil(self.topic, @"should be able to create a Topic instance");
}

- (void)testThatTopicCanBeNamed {
    XCTAssertEqualObjects(self.topic.name, @"iPhone", @"the Topic should have the name I gave it");
}

- (void)testThatTopicHasATag {
    XCTAssertEqualObjects(self.topic.tag, @"iphone", @"the Topic should have the tag I gave it");
}

- (void)testForAListOfQuestions {
    XCTAssertTrue([[self.topic recentQuestions] isKindOfClass:[NSArray class]], @"Topics should provide a list of recent questions");
}

- (void)testForInitiallyEmptyQuestionList {
    XCTAssertEqual([[self.topic recentQuestions] count], (NSUInteger)0, @"No questions added yet, count should be zero");
}

- (void)testAddingAQuestionToTheList {
    [self.topic addQuestion:self.question];
    XCTAssertEqual([[self.topic recentQuestions] count], (NSUInteger)1, @"Add a question, and the count of questions should go up");
}

- (void)testQuestionsAreListedChronologically {
    Question *q1 = [[Question alloc] init];
	q1.questionID = 1;
    q1.date = [NSDate distantPast];
    
    Question *q2 = [[Question alloc] init];
	q2.questionID = 2;
    q2.date = [NSDate distantFuture];
    
    [self.topic addQuestion:q1];
    [self.topic addQuestion:q2];
    
    NSArray *questions = [self.topic recentQuestions];
    Question *listedFirst = [questions objectAtIndex:0];
    Question *listedSecond = [questions objectAtIndex:1];
    
    XCTAssertEqualObjects([listedFirst.date laterDate:listedSecond.date], listedFirst.date, @"The later question should appear first in the list");
}

- (void)testLimitOfTwentyQuestions {
    Question *q1 = [[Question alloc] init];
    for (NSInteger i = 0; i < 25; i++) {
		q1.questionID = i;
        [self.topic addQuestion:q1];
    }
    XCTAssertTrue([[self.topic recentQuestions] count] < 21, @"There should never be more than twenty questions");
}

- (void)testThatTheSameQuestionCannotBeAddedTwiceToTheList {
	for (NSInteger i = 0; i < 2; i++) {
		[self.topic addQuestion:self.question];
	}
	XCTAssertEqual([[self.topic recentQuestions] count], (NSUInteger)1, @"Adding the same question twice should only yield one entry");
}

- (void)testThatDifferentQuestionsWithTheSameValueCannotBothBeInTheList {
	Question *otherQuestion = [[Question alloc] init];
	otherQuestion.questionID = self.question.questionID;
	[self.topic addQuestion:self.question];
	[self.topic addQuestion:otherQuestion];
	XCTAssertEqual([[self.topic recentQuestions] count], (NSUInteger)1, @"Adding questions with the same questionID value should only yield one entry");
}

@end
