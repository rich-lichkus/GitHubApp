//
//  CKGitHubNetworkController.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/22/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKGitHubNetworkController.h"
#import "CKAppDelegate.h"
#import "CKGitHubRepo.h"

@interface CKGitHubNetworkController ()

@property (strong, nonatomic) NSString *accessToken;
@property (weak, nonatomic) CKGitHubUser *weak_currentUser;

@end

@implementation CKGitHubNetworkController

-(instancetype)initWithCurrentUser:(CKGitHubUser*)currentUser{
    self = [super init];
    if(self){
        self.weak_currentUser = currentUser;
    }
    return self;
}

-(void)setAccessToken:(NSString *)accessToken{
    _accessToken = accessToken;
}

-(void)retrieveAllData{
    [self retrieveUser];      // Upon completion will retrieve user's followers and following
    [self retrieveRepos];
}

-(void)retrieveRepos{
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/repos?access_token=%@", self.accessToken]]];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: // All good
                {
                    NSError *jsonError = [NSError new];
                    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    [self.weak_currentUser addReposWithArrayOfDict:json];
                    [self.dataDelegate didDownload:kRepo];
                }
                    break;
                default:
                {
                    NSLog(@"%li", (long)httpResponse.statusCode);
                }
                    break;
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
    
    [dataTask resume];
}

-(void)retrieveUser{
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user?access_token=%@", self.accessToken]]];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: // All good
                {
                    NSError *jsonError = [NSError new];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    [self.weak_currentUser updateUsersInfo:json];
                    [self retrieveFollowing:[self removeOptionalParams:self.weak_currentUser.following_url]];
                    [self retrieveFollowers:self.weak_currentUser.followers_url];
                    [self.dataDelegate didDownload:kAuthenticatedUser];
                }
                    break;
                default:
                {
                    NSLog(@"%li", (long)httpResponse.statusCode);
                }
                    break;
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
    
    [dataTask resume];
}

-(void)retrieveFollowers:(NSString*)url_string{
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?access_token=%@", url_string, self.accessToken]]];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: // All good
                {
                    NSError *jsonError = [NSError new];
                    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    [self.weak_currentUser addFollowersWithArrayOfDict:json];
                    [self.dataDelegate didDownload:kUserFollowers];
                }
                    break;
                default:
                {
                    NSLog(@"%li", (long)httpResponse.statusCode);
                }
                    break;
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
    
    [dataTask resume];
}

-(void)retrieveFollowing:(NSString*)url_string{
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?access_token=%@", url_string, self.accessToken]]];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: // All good
                {
                    NSError *jsonError = [NSError new];
                    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    [self.weak_currentUser addFollowingWithArrayOfDict:json];
                    [self.dataDelegate didDownload:kUserFollowing];
                }
                    break;
                default:
                {
                    NSLog(@"%li", (long)httpResponse.statusCode);
                }
                    break;
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
    
    [dataTask resume];
}

                    
#pragma mark - Parse Methods

-(NSString*)removeOptionalParams:(NSString*)urlWithOptionals
{
    return [urlWithOptionals substringToIndex:[urlWithOptionals stringByDeletingLastPathComponent].length];
}

@end
