//
//  UserBuilder.m
//  BrowseOverflow
//
//  Created by Graham J Lee on 09/05/2011.
//  Copyright 2011 Fuzzy Aliens Ltd. All rights reserved.
//

#import "UserBuilder.h"
#import "Person.h"

@implementation UserBuilder

+ (Person *) personFromDictionary: (NSDictionary *) ownerValues  {
    NSString *name = [ownerValues objectForKey: @"display_name"];
    NSString *avatarURL = [ownerValues objectForKey: @"profile_image"];
    Person *owner = [[Person alloc] initWithName: name avatarLocation: avatarURL];
    return owner;
}


@end
