//
//  PCGitHubGraphics.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 CleverKnot LLC. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "PCGitHubGraphics.h"


@implementation PCGitHubGraphics

#pragma mark Cache

static UIImage* _imageOfThreeBarMenu = nil;
static UIImage* _imageOfUser = nil;
static UIImage* _imageOfRepo = nil;

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawThreeBarMenu;
{

    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(5, 7, 21, 3)];
    [UIColor.grayColor setFill];
    [rectanglePath fill];


    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(5, 13, 21, 3)];
    [UIColor.grayColor setFill];
    [rectangle2Path fill];


    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(5, 19, 21, 3)];
    [UIColor.grayColor setFill];
    [rectangle3Path fill];
}

+ (void)drawUser;
{

    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(9, 4, 11, 10)];
    [UIColor.whiteColor setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];


    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(5, 16, 19, 11) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: CGSizeMake(5.5, 5.5)];
    [rectanglePath closePath];
    [UIColor.whiteColor setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
}

+ (void)drawRepo;
{

    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(8.5, 9.5)];
    [bezierPath addLineToPoint: CGPointMake(3.5, 14.5)];
    [UIColor.whiteColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];


    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(3.5, 14.5)];
    [bezier2Path addLineToPoint: CGPointMake(8.5, 19.5)];
    [UIColor.whiteColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];


    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
    [bezier3Path moveToPoint: CGPointMake(21.5, 9.5)];
    [bezier3Path addLineToPoint: CGPointMake(26.5, 14.5)];
    [UIColor.whiteColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];


    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
    [bezier4Path moveToPoint: CGPointMake(26.5, 14.5)];
    [bezier4Path addLineToPoint: CGPointMake(21.5, 19.5)];
    [UIColor.whiteColor setStroke];
    bezier4Path.lineWidth = 1;
    [bezier4Path stroke];


    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = UIBezierPath.bezierPath;
    [bezier5Path moveToPoint: CGPointMake(18.5, 8.5)];
    [bezier5Path addCurveToPoint: CGPointMake(12.5, 20.5) controlPoint1: CGPointMake(12.5, 20.5) controlPoint2: CGPointMake(12.5, 20.5)];
    [UIColor.whiteColor setStroke];
    bezier5Path.lineWidth = 1;
    [bezier5Path stroke];
}

#pragma mark Generated Images

+ (UIImage*)imageOfThreeBarMenu;
{
    if (_imageOfThreeBarMenu)
        return _imageOfThreeBarMenu;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0f);
    [PCGitHubGraphics drawThreeBarMenu];
    _imageOfThreeBarMenu = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return _imageOfThreeBarMenu;
}

+ (UIImage*)imageOfUser;
{
    if (_imageOfUser)
        return _imageOfUser;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0f);
    [PCGitHubGraphics drawUser];
    _imageOfUser = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return _imageOfUser;
}

+ (UIImage*)imageOfRepo;
{
    if (_imageOfRepo)
        return _imageOfRepo;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0f);
    [PCGitHubGraphics drawRepo];
    _imageOfRepo = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return _imageOfRepo;
}

#pragma mark Customization Infrastructure

- (void)setThreeBarMenuTargets: (NSArray*)threeBarMenuTargets
{
    _threeBarMenuTargets = threeBarMenuTargets;

    for (id target in self.threeBarMenuTargets)
        [target setImage: PCGitHubGraphics.imageOfThreeBarMenu];
}

- (void)setUserTargets: (NSArray*)userTargets
{
    _userTargets = userTargets;

    for (id target in self.userTargets)
        [target setImage: PCGitHubGraphics.imageOfUser];
}

- (void)setRepoTargets: (NSArray*)repoTargets
{
    _repoTargets = repoTargets;

    for (id target in self.repoTargets)
        [target setImage: PCGitHubGraphics.imageOfRepo];
}


@end