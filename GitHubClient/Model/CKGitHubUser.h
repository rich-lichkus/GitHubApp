//
//  CKGitHubUser.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/21/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKGitHubUser : NSObject

@property (strong, nonatomic) NSString *gitHubAccessToken;

@property (strong, nonatomic) NSString *iD;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *repos_url;
@property (strong, nonatomic) NSString *followers_url;
@property (strong, nonatomic) NSString *following_url;
@property (strong, nonatomic) NSString *html_url;

@property (strong, nonatomic) NSMutableArray *privateRepos;
@property (strong, nonatomic) NSMutableArray *repos;
@property (strong, nonatomic) NSMutableArray *followers;
@property (strong, nonatomic) NSMutableArray *following;

-(instancetype)initWithGitHubJSON:(NSDictionary*)infoDict;
-(void)updateUsersInfo:(NSDictionary*)infoDict;

-(void)addReposWithArrayOfDict:(NSArray*)arrayOfDict;
-(void)addFollowersWithArrayOfDict:(NSArray*)arrayOfDict;
-(void)addFollowingWithArrayOfDict:(NSArray*)arrayOfDict;

@end
