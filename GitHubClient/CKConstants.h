//
//  CKConstants.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, kLoginElementTags){
    kLoginUsernameTxtTag = 0,
    kLoginPasswordTxtTag
};

typedef NS_ENUM(NSInteger, kWebService) {
    kGitHub = 0,
    kFacebook,
    kFlickr,
    kGoogle
};

typedef NS_ENUM(NSInteger, kCallbackType) {
    kOAuth = 0
};

typedef NS_ENUM(NSInteger, kAsset) {
    kToken = 0
};

typedef NS_ENUM(NSInteger, kSelectedMenuOption) {
    kMyAccountMenu = 0,
    kRepoMenu,
    kFollowersMenu,
    kFollowingMenu,
    kLogoutMenu
};

typedef NS_ENUM(NSInteger, kGitHubDataType){
    kAuthenticatedUser = 0,
    kRepo = 1,
    kUserFollowers = 2,
    kUserFollowing = 3
};







