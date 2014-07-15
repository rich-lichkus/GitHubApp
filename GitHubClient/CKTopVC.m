//
//  CKTopVC.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKTopVC.h"
#import "PCGitHubGraphics.h"

@interface CKTopVC() <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblDisplayItems;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbiMenu;
@property (weak, nonatomic) IBOutlet UISearchBar *srcSearchBar;

@end

@implementation CKTopVC

#pragma mark - View

- (void)viewDidLoad {
    
    [self configureUIElements];
    
    [self configureTableView];
}

#pragma mark - Configurations

- (void)configureUIElements {
    [self.bbiMenu setImage:[PCGitHubGraphics imageOfThreeBarMenu]];
}

- (void)configureTableView{
    self.tblDisplayItems.delegate = self;
    self.tblDisplayItems.dataSource = self;
}

#pragma mark - Delegate

- (IBAction)pressedMenu:(id)sender {
    [self.delegate menuClicked];
    NSLog(@"pressedMenu");
}

#pragma mark - Search Bar 


#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"displayResult" forIndexPath:indexPath];
    
    cell.textLabel.text = @"Repo";
    
    return cell;
}


#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
