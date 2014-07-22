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

#pragma mark - Init

-(instancetype)initWithGitHubJSON:(NSDictionary*)infoDict {
    self = [super init];
    if(self){
        self.iD = infoDict[@"id"];
        self.name = infoDict[@"name"];
        self.login = infoDict[@"login"];
        self.avatar_url = infoDict[@"avatar_url"];
        self.repos_url = infoDict[@"repos_url"];
        self.followers_url = infoDict[@"followers_url"];
        self.following_url = infoDict[@"following_url"];
        self.html_url = infoDict[@"html_url"];
    }
    return self;
}

#pragma mark - Methods

-(void)updateUsersInfo:(NSDictionary *)infoDict{
    
    self.iD = infoDict[@"id"];
    self.name = infoDict[@"name"];
    self.login = infoDict[@"login"];
    self.avatar_url = infoDict[@"avatar_url"];
    self.repos_url = infoDict[@"repos_url"];
    self.followers_url = infoDict[@"followers_url"];
    self.following_url = infoDict[@"following_url"];
    self.html_url = infoDict[@"html_url"];
}

-(void)addReposWithArrayOfDict:(NSArray *)arrayOfDict{
    for(NSDictionary *repoDict in arrayOfDict){
        CKGitHubRepo *repo = [[CKGitHubRepo alloc] initWithGitHubJSON:repoDict];
        [self.repos addObject:repo];
    }
}

-(void)addFollowersWithArrayOfDict:(NSArray *)arrayOfDict{
    for(NSDictionary *userInfo in arrayOfDict){
        CKGitHubUser *user = [[CKGitHubUser alloc] initWithGitHubJSON:userInfo];
        [self.followers addObject:user];
    }
}

-(void)addFollowingWithArrayOfDict:(NSArray *)arrayOfDict{
    for(NSDictionary *userInfo in arrayOfDict){
        CKGitHubUser *user = [[CKGitHubUser alloc] initWithGitHubJSON:userInfo];
        [self.following addObject:user];
    }
}

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

-(NSMutableArray*)followers{
    if(!_followers){
        _followers = [[NSMutableArray alloc] init];
    }
    return _followers;
}

-(NSMutableArray*)following{
    if(!_following){
        _following = [[NSMutableArray alloc] init];
    }
    return _following;
}

@end
