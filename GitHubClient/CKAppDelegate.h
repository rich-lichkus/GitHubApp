//
//  CKAppDelegate.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKOAuthController.h"
#import "CKGitHubUser.h"

@interface CKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CKOAuthController *oauthController;
@property (strong, nonatomic) CKGitHubUser *currentUser;

@end
