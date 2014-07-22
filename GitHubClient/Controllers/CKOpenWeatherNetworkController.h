//
//  CKOpenWeatherNetworkController.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/22/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKOpenWeatherNCDataDelegate <NSObject>

-(void) didDownloadImage:(UIImage*)image;   // TODO: Refactor to pass saved image's url

@end

@interface CKOpenWeatherNetworkController : NSObject

@property (nonatomic, unsafe_unretained) id<CKOpenWeatherNCDataDelegate> dataDelegate;

-(void)getWeatherForCity:(NSString*)cityName andState:(NSString*)stateAbbreviation;
-(void)get:(NSInteger)number catsWithFormat:(NSString*)format;

@end
