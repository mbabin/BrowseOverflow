//
//  Question.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 21/02/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "Question.h"
#import "Person.h"

@interface Question ()
@property (nonatomic) NSMutableSet *answerSet;
@end

@implementation Question

- (id)init {
    if ((self = [super init])) {
        _answerSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addAnswer:(Answer *)answer {
    [self.answerSet addObject:answer];
}

- (NSArray *)answers {
    return [[self.answerSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (BOOL)isEqual:(id)other {
	if ([other isKindOfClass:[self class]]) {
		return (self.questionID == [other questionID]);
	} else {
		return [super isEqual:other];
	}
}

- (NSUInteger)hash {
    return self.questionID;
}

@end
