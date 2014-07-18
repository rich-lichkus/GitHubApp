//
//  CKActivityIndicator.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/17/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKActivityIndicator.h"
#import "PCGitHubGraphics.h"

@implementation CKActivityIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [PCGitHubGraphics drawProgressBarWithRotation:50];
}

-(void)animationDidStart:(CAAnimation *)anim{

}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

}


@end
