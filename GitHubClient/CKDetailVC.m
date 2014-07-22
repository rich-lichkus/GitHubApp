//
//  CKDetailVC.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKDetailVC.h"

@interface CKDetailVC ()

@property (strong, nonatomic) NSString *urlString;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CKDetailVC

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"view appear");
    [self.webView reload];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"view appear");
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

@end
