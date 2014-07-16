//
//  CKOAuthController.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/15/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKOAuthController.h"

#define APPLICATION_NAME @"iGitHub"
#define GITHUB_CLIENT_ID @"b7e10d79af8fd54aae59"
#define GITHUB_CLIENT_SECRET @"cda8f903365f93abe4f75c4d176591fdb4111895"
#define GITHUB_CALLBACK_URI @"igithub://git_callback"
#define GITHUB_OAUTH_URL  @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"


@interface CKOAuthController ()

@property (strong, nonatomic) NSString *accessToken;

@end

@implementation CKOAuthController

-(void)authenticateUser:(NSURL*)url{
    
    NSString *code = [self convertURLintoCode:url];

    NSString *post = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@&redirect_uri=%@", GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, code, GITHUB_CALLBACK_URI];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)post.length];

    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        
        if(httpResponse.statusCode == 200){
            self.accessToken = [self convertResponseIntoToken:data];
        } else {
            NSLog(@"error: %@", error.description);
        }
        
        NSString *repoString = [NSString stringWithFormat:@"https://api.github.com/user/repos?access_token=%@", self.accessToken];
        
        NSURL *repoURL = [NSURL URLWithString:repoString];
        NSData *repoData = [NSData dataWithContentsOfURL:repoURL];
        NSError *repoerror;
        NSMutableDictionary *repoDict = [NSJSONSerialization JSONObjectWithData:repoData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&repoerror];
        [self.dataDelegate didDownloadRepos:repoDict];
    }];
    
    [postDataTask resume];
    
}

-(NSString *)convertURLintoCode:(NSURL *)url
{
    NSString *query = [url query];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSLog(@"%@",components);
    NSArray *params = [components[0] componentsSeparatedByString:@"="];
    NSLog(@"%@",params);
    return params[1];
}

-(NSString *)convertResponseIntoToken:(NSData *)data
{
    NSString *tokenResponse = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    
    NSArray *tokencomponents = [tokenResponse componentsSeparatedByString:@"&"];
    NSString *accesstokenwithcode = [tokencomponents objectAtIndex:0];
    NSArray *access_token_array = [accesstokenwithcode componentsSeparatedByString:@"="];
    return access_token_array[1];
}

-(void)requestOAuthAccess
{
    NSString *urlString = [NSString stringWithFormat:GITHUB_OAUTH_URL,GITHUB_CLIENT_ID,GITHUB_CALLBACK_URI,@"user,repos"];
    NSLog(@" %@", urlString);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end