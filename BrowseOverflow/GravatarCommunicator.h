//
//  GravatarCommunicator.h
//  BrowseOverflow
//
//  Created by Graham J Lee on 26/05/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GravatarCommunicatorDelegate.h"

@interface GravatarCommunicator : NSObject

@property (nonatomic) NSURL *url;
@property (weak) id <GravatarCommunicatorDelegate> delegate;

- (void)fetchDataForURL:(NSURL *)location;

@end
