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