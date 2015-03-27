//
//  StackOverflowCommunicator.h
//  BrowseOverflow
//
//  Created by Graham J Lee on 17/03/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowCommunicatorDelegate.h"

@interface StackOverflowCommunicator : NSObject <NSURLSessionDataDelegate>

@property (weak) id <StackOverflowCommunicatorDelegate> delegate;

+ (instancetype)communicatorWithDelegate:(id <StackOverflowCommunicatorDelegate>)delegate;
- (id)init __attribute__((unavailable("Use +communicatorWithDelegate: instead")));

- (void)searchForQuestionsWithTag: (NSString *)tag;
- (void)downloadInformationForQuestionWithID: (NSInteger)identifier;
- (void)downloadAnswersToQuestionWithID: (NSInteger)identifier;

- (void)cancelLastRequest;
@end

extern NSString *StackOverflowCommunicatorErrorDomain;
