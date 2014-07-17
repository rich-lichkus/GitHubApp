//
//  CKOAuthController.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/15/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKOAuthControllerDataDelegate <NSObject>

- (void)didDownloadRepos:(NSMutableDictionary*)repoDictionary;

@end


@interface CKOAuthController : NSObject

@property (nonatomic, unsafe_unretained) id<CKOAuthControllerDataDelegate> dataDelegate;

-(void)authenticateUser:(NSURL*)url;
-(void)requestOAuthAccess;

-(void)getUser;

-(void)getWeatherForCity:(NSString*)cityName andState:(NSString*)stateAbbreviation;

@end
