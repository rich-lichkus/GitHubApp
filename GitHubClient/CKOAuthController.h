//
//  CKOAuthController.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/15/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKGitHubUser.h"

@protocol CKOAuthControllerDataDelegate <NSObject>

- (void)didAuthenticateUser:(BOOL)flag;

@end

@interface CKOAuthController : NSObject

@property (nonatomic, unsafe_unretained) id<CKOAuthControllerDataDelegate> dataDelegate;

-(instancetype)initWithCurrentUser:(CKGitHubUser*)currentUser;

-(void)authenticateUserWithWebService:(kWebService)name;
-(void)processWebServiceCallback:(NSURL*)url;
-(NSString*)gitHubAccessToken;

@end
