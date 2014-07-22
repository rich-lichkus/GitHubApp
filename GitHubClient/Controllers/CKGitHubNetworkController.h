//
//  CKGitHubNetworkController.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/22/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKGitHubUser.h"

@protocol CKGitHubNCDataDelegate <NSObject>

- (void)didDownload:(kGitHubDataType)dataType;

@end

@interface CKGitHubNetworkController : NSObject

@property (nonatomic, unsafe_unretained) id<CKGitHubNCDataDelegate> dataDelegate;

-(instancetype)initWithCurrentUser:(CKGitHubUser*)currentUser;

-(void)setAccessToken:(NSString*)accessToken;

-(void)retrieveAllData;
-(void)retrieveRepos;
-(void)retrieveUser;

@end
