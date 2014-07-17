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


@interface CKOAuthController () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

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


-(void)getWeatherForCity:(NSString*)cityName andState:(NSString*)stateAbbreviation{
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat: @"http://api.openweathermap.org/data/2.5/weather?q=%@,%@",cityName, stateAbbreviation]]];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
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
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://explosionhub.com/wp-content/uploads/2012/07/kitten-next-to-fish-in-a-fish-bowl.jpg"]];
    
    NSURLSessionDownloadTask *downloadTask = [downloadSession downloadTaskWithRequest:urlRequest];
    
    [downloadTask resume];

}

#pragma mark - Session Delegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    NSLog(@"Delegate Called.");
}

#pragma mark - Download Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    NSLog(@"location:%@", location);
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *catImage = [UIImage imageWithData:data];
    
    [self.dataDelegate didDownloadImage:catImage];
//    NSLog(@"%f,%f",catImage.size.width,catImage.size.height);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    NSLog(@"bytesWritten: %lli, totalBytesWritten: %lli, totalBytes: %lli", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


@end
