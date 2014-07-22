//
//  CKGitHubRepo.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/21/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKGitHubRepo.h"

@interface CKGitHubRepo ()

@end

@implementation CKGitHubRepo

#pragma mark - Instantiation

-(instancetype)initWithGitHubJSON:(NSDictionary*)jsonDictionary{
    self = [super init];
    if(self){
        self.name = jsonDictionary[@"name"];
        self.private = jsonDictionary[@"private"];
        self.html_url = jsonDictionary[@"html_url"];
    }
    return self;
}

@end
