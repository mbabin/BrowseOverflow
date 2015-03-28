//
//  Topic.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 17/02/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "Topic.h"
#import "Question.h"

@interface Topic ()

@property (nonatomic) NSSet *questions;

- (NSArray *)sortQuestionsLatestFirst: (NSArray *)questionList;

@end

@implementation Topic

- (id)initWithName:(NSString *)newName tag: (NSString *)newTag {
	self = [super init];
    if (self) {
        _name = [newName copy];
        _tag = [newTag copy];
        _questions = [[NSSet alloc] init];
    }
    return self;
}


- (void)addQuestion: (Question *)question {
    NSSet *newQuestions = [self.questions setByAddingObject:question];
	NSArray *latestQuestions = [newQuestions allObjects];
    if ([newQuestions count] > 20) {
        latestQuestions = [self sortQuestionsLatestFirst:latestQuestions];
        latestQuestions = [latestQuestions subarrayWithRange: NSMakeRange(0, 20)];
    }
    self.questions = [NSSet setWithArray:latestQuestions];
}

- (NSArray *)recentQuestions {
	return [self sortQuestionsLatestFirst:[self.questions allObjects]];
}

- (NSArray *)sortQuestionsLatestFirst: (NSArray *)questionList {
    return [questionList sortedArrayUsingComparator: ^(id obj1, id obj2) {
        Question *q1 = (Question *)obj1;
        Question *q2 = (Question *)obj2;
        NSComparisonResult sortOrder = [q1.date compare: q2.date];
        switch (sortOrder) {
            case NSOrderedAscending:
                return NSOrderedDescending;
            case NSOrderedDescending:
                return NSOrderedAscending;
            default:
                return NSOrderedSame;
        }
    }];
}

@end
