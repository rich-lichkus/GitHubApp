//
//  CKTopVC.h
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CKTopVCDelegate <NSObject>

- (void)menuClicked;

@end


@interface CKTopVC : UIViewController

@property (nonatomic, unsafe_unretained) id<CKTopVCDelegate> delegate;

-(void)selectedMenu:(kSelectedMenuOption)option;

@end
