//
//  CKOAuthController.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/15/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKOAuthControllerDataDelegate <NSObject>

@optional
- (void)didDownloadRepos:(NSMutableArray*)repoDictionary;
- (void)didDownloadImage:(UIImage*)uiimage;
- (void)didAuthenticateUser:(BOOL)flag;

@end

@interface CKOAuthController : NSObject

@property (nonatomic, unsafe_unretained) id<CKOAuthControllerDataDelegate> dataDelegate;

-(void)authenticateUserWithWebService:(kWebService)name;
-(void)processWebServiceCallback:(NSURL*)url;

-(void)gitHubRetrieveRepos;

-(void)getWeatherForCity:(NSString*)cityName andState:(NSString*)stateAbbreviation;
-(void)get:(NSInteger)number catsWithFormat:(NSString*)format;

@end
