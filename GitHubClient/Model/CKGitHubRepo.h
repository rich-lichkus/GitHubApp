//
//  CKGitHubRepo.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/21/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKGitHubRepo : NSObject

@property (nonatomic) BOOL private;
@property (strong, nonatomic) NSString *name;

-(instancetype)initWithGitHubJSON:(NSDictionary*)jsonDictionary;

@end
