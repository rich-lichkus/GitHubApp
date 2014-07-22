//
//  CKOAuthController.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/15/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKAppDelegate.h"
#import "CKOAuthController.h"
#import "CKGitHubRepo.h"

#define APPLICATION_NAME @"iGitHub"

// ! Parse Dependent Format: //key=value!key=value...key=value?
#define GENERIC_CALLBACK_URI @"igithub://web_service=%zd!call_back=%zd"
#define GENERIC_ACCESS_KEY @"web_service=%zd!asset=%zd"
// GitHub
#define GITHUB_OAUTH_URL  @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"
#define GITHUB_CLIENT_ID @"b7e10d79af8fd54aae59"
#define GITHUB_CLIENT_SECRET @"cda8f903365f93abe4f75c4d176591fdb4111895"
#define GITHUB_POST_TOKEN_URL @"https://github.com/login/oauth/access_token"

@interface CKOAuthController () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (weak, nonatomic) CKGitHubUser *weak_currentUser;
@property (strong, nonatomic) NSString *gitHubAccessToken;

@end

@implementation CKOAuthController

-(instancetype)initWithCurrentUser:(CKGitHubUser*)currentUser{
    self = [super init];
    if(self){
        self.weak_currentUser = currentUser;
    }
    return self;
}

-(void)authenticateUserWithWebService:(kWebService)name{
    
    NSString *requestAuthenticationURL;
    BOOL authenticated = NO;
    
    switch (name) {
        case kGitHub: {
            NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:GENERIC_ACCESS_KEY,kGitHub,kToken]];
            if(accessToken){
                self.gitHubAccessToken = accessToken;
                NSAssert(self.gitHubAccessToken, @"Github access token is nil. Rectify.");
                authenticated = YES;
                [self.dataDelegate didAuthenticateUser:YES];
                
            } else {
                // Requesting a token with access to user info and user's public reposs
                requestAuthenticationURL = [NSString stringWithFormat:GITHUB_OAUTH_URL,GITHUB_CLIENT_ID,[NSString stringWithFormat: GENERIC_CALLBACK_URI,kGitHub,kOAuth],@"user,public_repo"];
                // On redirect, github will supply a temporary code in "code" parameter
            }
        }
            break;
        case kGoogle: {
        
        }
            break;
        case kFacebook: {
        
        }
            break;
        case kFlickr: {
        
        }
            break;
    }
    if(!authenticated){
        // Open request authentication url in safari
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestAuthenticationURL]];
        // Redirect will call method in app delegate
    }
}

-(void)processWebServiceCallback:(NSURL*)url {
    
    NSMutableDictionary *callBackComponents = [self parseCallBackComponents:url];
    
    switch ([[callBackComponents objectForKey:@"web_service"] integerValue]) {
        case kGitHub: {
            switch ([[callBackComponents objectForKey:@"call_back"] integerValue]) {
                case kOAuth:
                        [self gitHubRetrieveToken:url];
                    break;
            }
        }
            break;
        case kGoogle: {
            
        }
            break;
        case kFacebook: {
            
        }
            break;
        case kFlickr: {
            
        }
            break;
    }

}

#pragma mark - GitHub OAuth

-(NSString*)gitHubAccessToken{
    return _gitHubAccessToken;
}

-(void)gitHubRetrieveToken:(NSURL*)url{
    NSString *temporaryCode = [self parseGitHubTempCode:url];
    NSString *paramsString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@&redirect_uri=%@",
                           GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, temporaryCode, [NSString stringWithFormat:GENERIC_CALLBACK_URI,kGitHub,kOAuth]];
    NSData *postData = [paramsString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)paramsString.length];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GITHUB_POST_TOKEN_URL]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *retrieveAccessToken = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            
            switch (httpResponse.statusCode) {
                case 200: { // All good
                    self.gitHubAccessToken = [[self dictionaryGitHubFromData:data] objectForKey:@"access_token"];
                    NSAssert(self.gitHubAccessToken, @"Do not have access token. Rectify immediately.");
                    [[NSUserDefaults standardUserDefaults] setObject:self.gitHubAccessToken forKey:[NSString stringWithFormat:GENERIC_ACCESS_KEY,kGitHub,kToken]];
                    [self.dataDelegate didAuthenticateUser:YES];
                }
                    break;
                default:
                    NSLog(@"error: %ld", (long)httpResponse.statusCode);
                    break;
            }
            
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
    [retrieveAccessToken resume];
}

-(NSString*) parseGitHubTempCode:(NSURL*)url{
    NSArray *queryComponents = [[url query] componentsSeparatedByString:@"&"];
    return [queryComponents[0] componentsSeparatedByString:@"="][1];
}

-(NSMutableDictionary*)dictionaryGitHubFromData:(NSData*)data{
    NSString *tokenResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSMutableDictionary *tokenParams = [[NSMutableDictionary alloc] init];
    NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@"&"];
    
    for (NSString *component in tokenComponents) {
        NSArray *params = [component componentsSeparatedByString:@"="];
        [tokenParams setObject:params[1] forKey:params[0]];
    }
    
    return tokenParams;
}

#pragma mark - Session Delegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    NSLog(@"%lu", (unsigned long)dataTask.taskIdentifier);
    NSLog(@"%@", dataTask.taskDescription);
    NSLog(@"Delegate Called.");
}

#pragma mark - Data Delegate 
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler{
    NSLog(@"%@",proposedResponse);
}

#pragma mark - Parsing Functions
-(NSMutableDictionary*)parseCallBackComponents:(NSURL*)callback{
    
    NSArray *callBackComponents = [callback.host componentsSeparatedByString:@"!"];
    NSMutableDictionary *callbackParams = [[NSMutableDictionary alloc] init];
    
    for (NSString *component in callBackComponents) {
        NSArray *params = [component componentsSeparatedByString:@"="];
        [callbackParams setObject:[NSNumber numberWithInteger:[params[1] integerValue]] forKey:params[0]];
    }
    return callbackParams;
}



@end
