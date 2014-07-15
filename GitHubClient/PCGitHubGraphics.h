//
//  PCGitHubGraphics.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 CleverKnot LLC. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PCGitHubGraphics : NSObject

// iOS Controls Customization Outlets
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* threeBarMenuTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* userTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* repoTargets;

// Drawing Methods
+ (void)drawThreeBarMenu;
+ (void)drawUser;
+ (void)drawRepo;

// Generated Images
+ (UIImage*)imageOfThreeBarMenu;
+ (UIImage*)imageOfUser;
+ (UIImage*)imageOfRepo;

@end