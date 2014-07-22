//
//  CKOAuthController.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/15/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKAppDelegate.h"
#import "CKOAuthController.h"
#import <XCTest/XCTest.h>
#import "CKGitHubUser.h"
#import "CKGitHubRepo.h"

#define APPLICATION_NAME @"iGitHub"

// ! Parse Dependent Format: //key=value!key=value...key=value?
#define GENERIC_CALLBACK_URI @"igithub://web_service=%zd!call_back=%zd"
#define GENERIC_ACCESS_KEY @"web_service=%zd!asset=%zd"

#define GITHUB_CLIENT_ID @"b7e10d79af8fd54aae59"
#define GITHUB_CLIENT_SECRET @"cda8f903365f93abe4f75c4d176591fdb4111895"
#define GITHUB_OAUTH_URL  @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"
#define GITHUB_POST_TOKEN_URL @"https://github.com/login/oauth/access_token"

@interface CKOAuthController () <NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (weak, nonatomic) CKGitHubUser *weak_currentUser;
@property (strong, nonatomic) NSString *accessToken;

@end

@implementation CKOAuthController

-(instancetype)init{
    self = [super init];
    if(self){
        self.weak_currentUser = ((CKAppDelegate*)[[UIApplication sharedApplication] delegate]).currentUser;
    }
    return self;
}

-(void)authenticateUserWithWebService:(kWebService)name{
    
    NSString *requestAuthenticationURL;
    BOOL authenticated = NO;
    
    switch (name) {
        case kGitHub: {
            NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:GENERIC_ACCESS_KEY,kGitHub,kToken]];
            if(access_token){
                self.accessToken = access_token;
                NSAssert(self.accessToken, @"Github access token is nil. Rectify.");
                authenticated = YES;
                [self.dataDelegate didAuthenticateUser:YES];
                [self gitHubRetrieveRepos];
                [self gitHubRetrieveUser];
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

#pragma mark - GitHub Methods

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
                    self.accessToken = [[self dictionaryGitHubFromData:data] objectForKey:@"access_token"];
                    NSAssert(self.accessToken, @"Do not have access token. Rectify immediately.");
                    [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:[NSString stringWithFormat:GENERIC_ACCESS_KEY,kGitHub,kToken]];
                    [self.dataDelegate didAuthenticateUser:YES];
                    [self gitHubRetrieveRepos];
                    [self gitHubRetrieveUser];
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

-(void)gitHubRetrieveRepos{
    
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
                    
                    for(NSDictionary *repoDict in json){
                        CKGitHubRepo *repo = [[CKGitHubRepo alloc] initWithGitHubJSON:repoDict];
                        [self.weak_currentUser.repos addObject:repo];
                    }
                
                    [self.dataDelegate didDownloadRepos:self.weak_currentUser.repos];
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

-(void)gitHubRetrieveUser{
    
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
                    
                    [self gitHubRetrieveFollowers:json[@"followers_url"]];
//                    [self gitHubRetrieveFollowing:json[0][@"following_url"]];
                    
//                    [self.dataDelegate didDownloadRepos:self.weak_currentUser.repos];
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

-(void)gitHubRetrieveFollowers:(NSString*)url_string{
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

//                    [self.dataDelegate didDownloadRepos:self.weak_currentUser.repos];
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

-(void)gitHubRetrieveFollowing:(NSURL*)url{

}


#pragma mark - NSURLSession Practice

-(void)getWeatherForCity:(NSString*)cityName andState:(NSString*)stateAbbreviation{
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat: @"http://api.openweathermap.org/data/2.5/weather?q=%@,%@",cityName, stateAbbreviation]]];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: // All good
                {
                    NSError *jsonError = [NSError new];
                    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    
                    float temperatureKelvin = [[[json valueForKey:@"main"] valueForKey:@"temp"] floatValue];
                    float temperatureFar = (temperatureKelvin - 273.0)*1.8 +32;
                    
                    NSLog(@"Today's temperature in %@, %@ is %f degress.", json[@"name"], json[@"sys"][@"country"], temperatureFar);
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

-(void)get:(NSInteger)number catsWithFormat:(NSString*)format{
    
    NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://explosionhub.com/wp-content/uploads/2012/07/kitten-next-to-fish-in-a-fish-bowl.jpg"] ];
    
    NSURLSessionDownloadTask *downloadTask = [downloadSession downloadTaskWithRequest:urlRequest];
    
    [downloadTask resume];

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

#pragma mark - Download Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    NSLog(@"location:%@", location);
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *catImage = [UIImage imageWithData:data];
    
    [self.dataDelegate didDownloadImage:catImage];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
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




//-(void)authenticateUser:(NSURL*)url {
//
//    NSString *code = [self convertURLintoCode:url];
//
//    NSString *post = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@&redirect_uri=%@", GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, code, [NSString stringWithFormat: GENERIC_CALLBACK_URI,kGitHub,kOAuth]];
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)post.length];
//
//    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//
//    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
//    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [urlRequest setHTTPBody:postData];
//
//    NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//
//        if(httpResponse.statusCode == 200){
//            self.accessToken = [self convertResponseIntoToken:data];
//        } else {
//            NSLog(@"error: %@", error.description);
//        }
//
//        NSString *repoString = [NSString stringWithFormat:@"https://api.github.com/user/repos?access_token=%@", self.accessToken];
//
//        NSURL *repoURL = [NSURL URLWithString:repoString];
//        NSData *repoData = [NSData dataWithContentsOfURL:repoURL];
//        NSError *repoerror;
//        NSMutableDictionary *repoDict = [NSJSONSerialization JSONObjectWithData:repoData
//                                                                        options:NSJSONReadingMutableContainers
//                                                                          error:&repoerror];
//        //[self.dataDelegate didDownloadRepos:repoDict];
//    }];
//    
//    [postDataTask resume];
//}

@end
