//
//  CKGitHubUser.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/21/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKGitHubUser : NSObject

@property (strong, nonatomic) NSMutableArray *privateRepos;
@property (strong, nonatomic) NSMutableArray *repos;


@end
