//
//  CKOpenWeatherNetworkController.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/22/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKOpenWeatherNetworkController.h"

@interface CKOpenWeatherNetworkController () <NSURLSessionDataDelegate, NSURLSessionDelegate>

@end

@implementation CKOpenWeatherNetworkController

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

#pragma mark - Download Image

-(void)get:(NSInteger)number catsWithFormat:(NSString*)format{
    
    NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://explosionhub.com/wp-content/uploads/2012/07/kitten-next-to-fish-in-a-fish-bowl.jpg"] ];
    
    NSURLSessionDownloadTask *downloadTask = [downloadSession downloadTaskWithRequest:urlRequest];
    
    [downloadTask resume];
    
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

@end
