//
//  CKGitHubUser.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/21/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKGitHubUser.h"
#import "CKGitHubRepo.h"

@interface CKGitHubUser ()

@end

@implementation CKGitHubUser


#pragma mark - Lazy Instantiating

-(NSMutableArray*)privateRepos{
    if(!_privateRepos){
        _privateRepos = [[NSMutableArray alloc] init];
    }
    return _privateRepos;
}

-(NSMutableArray*)repos{
    if(!_repos){
        _repos = [[NSMutableArray alloc] init];
    }
    return _repos;
}


@end
