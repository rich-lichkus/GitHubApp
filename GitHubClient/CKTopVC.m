//
//  CKTopVC.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKAppDelegate.h"
#import "CKTopVC.h"
#import "PCGitHubGraphics.h"
#import "CKOAuthController.h"
#import "CKGitHubUser.h"
#import "CKGitHubRepo.h"

@interface CKTopVC() <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, CKGitHubNCDataDelegate>

@property (weak, nonatomic) CKGitHubUser *weak_currentUser;

@property (nonatomic) kSelectedMenuOption selectedMenu;
@property (strong, nonatomic) NSMutableArray *allItems;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tblDisplayItems;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbiMenu;
@property (weak, nonatomic) IBOutlet UISearchBar *srcSearchBar;

@end

@implementation CKTopVC

#pragma mark - View

- (void)viewDidLoad {
    
    [self configureCurrentUser];
    
    [self configureUIElements];
    
    [self configureTableView];
}

#pragma mark - Configurations

-(void)configureCurrentUser{
    self.weak_currentUser = ((CKAppDelegate*)[[UIApplication sharedApplication] delegate]).currentUser;
    self.selectedMenu = kRepoMenu;
    self.allItems = self.weak_currentUser.repos;
}

- (void)configureUIElements {
    [self.bbiMenu setImage:[PCGitHubGraphics imageOfThreeBarMenu]];
}

- (void)configureTableView{
    self.tblDisplayItems.delegate = self;
    self.tblDisplayItems.dataSource = self;
}

#pragma mark - Target Action

- (IBAction)pressedMenu:(id)sender {
    [self.delegate menuClicked];
}

#pragma mark - Delegation
-(void)didDownload:(kGitHubDataType)dataType{
    NSLog(@"Downloaded: %zd", dataType);
    if(dataType == (kGitHubDataType)self.selectedMenu){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tblDisplayItems reloadData];        
        }];
    }
}

#pragma mark - Search

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSPredicate *predicate;
    
    switch (self.selectedMenu) {
        case kMyAccountMenu:
        case kRepoMenu:
        {
            predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", searchString];
        }
            break;
        case kFollowersMenu:
        case kFollowingMenu:
        {
            predicate = [NSPredicate predicateWithFormat:@"login BEGINSWITH[cd] %@", searchString];
        }
            break;
        case kLogoutMenu: // N/A
        case kBlankMenu:  // N/A
            break;
    }
    
    self.searchResults = [self.allItems filteredArrayUsingPredicate:predicate];

    return YES;
}

#pragma mark - Methods

-(void)selectedMenu:(kSelectedMenuOption)option{
    self.selectedMenu = option;
    switch (option) {
        case kMyAccountMenu:
            self.title = @"My Account";
            self.allItems = [@[self.weak_currentUser]mutableCopy];
            break;
        case kRepoMenu:
            self.title = @"Repos";
            self.allItems = self.weak_currentUser.repos;
            break;
        case kFollowersMenu:
            self.title = @"Followers";
            self.allItems = self.weak_currentUser.followers;
            break;
        case kFollowingMenu:
            self.title = @"Following";
            self.allItems = self.weak_currentUser.following;
            break;
        case kBlankMenu:  // N/A
        case kLogoutMenu: // N/A
            break;
    }
    
    [self.tblDisplayItems reloadData];
}


#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger numRows =0;
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        numRows = self.searchResults.count;
    } else {
        switch (self.selectedMenu) {
            case kMyAccountMenu:
            {
                numRows = 1;
            }
                break;
            case kRepoMenu:
            {
                numRows = self.weak_currentUser.repos.count;
            }
                break;
            case kFollowersMenu:
            {
                numRows = self.weak_currentUser.followers.count;
            }
                break;
            case kFollowingMenu:
            {
                numRows = self.weak_currentUser.following.count;
            }
                break;
            case kLogoutMenu:
            {
                // N/A
            }
                break;
            case kBlankMenu:
            {
                // N/A
            }
                break;
        }
    }
    return numRows;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
      /// Interesting 
      Symptoms:  Push segue was not showing
      Situation: Search display controller with view containing a tableview
      Fix:       in dequeue method replaced tableview for self.tblDisplayItems
    */
    UITableViewCell *cell = [self.tblDisplayItems dequeueReusableCellWithIdentifier:@"displayResult" forIndexPath:indexPath];
    
    switch (self.selectedMenu) {
        case kMyAccountMenu:
        {
            if(tableView == self.searchDisplayController.searchResultsTableView){
                CKGitHubUser *currentUser = self.searchResults[indexPath.row];
                cell.textLabel.text = currentUser.name;
            } else {
                cell.textLabel.text = self.weak_currentUser.name;
            }
        }
            break;
        case kRepoMenu:
        {
            if(tableView == self.searchDisplayController.searchResultsTableView){
                CKGitHubRepo *currentRepo = self.searchResults[indexPath.row];
                cell.textLabel.text = currentRepo.name;
            } else {
                CKGitHubRepo *currentRepo = self.weak_currentUser.repos[indexPath.row];
                cell.textLabel.text = currentRepo.name;
            }
        }
            break;
        case kFollowersMenu:
        {
            if(tableView == self.searchDisplayController.searchResultsTableView){
                CKGitHubUser *currentUser = self.searchResults[indexPath.row];
                cell.textLabel.text = currentUser.login;
            } else {
                CKGitHubUser *currentUser = self.weak_currentUser.followers[indexPath.row];
                cell.textLabel.text = currentUser.login;
            }
            break;
        }
        case kFollowingMenu:
        {
            if(tableView == self.searchDisplayController.searchResultsTableView){
                CKGitHubUser *currentUser = self.searchResults[indexPath.row];
                cell.textLabel.text = currentUser.login;
            } else {
                CKGitHubUser *currentUser = self.weak_currentUser.following[indexPath.row];
                cell.textLabel.text = currentUser.login;
            }
        }
            break;
        case kLogoutMenu:
        {
            // N/A
        }
            break;
        case kBlankMenu:
        {
            // N/A
        }
            break;
    }

    return cell;
}

#pragma mark - Lazy

- (NSArray*)searchResults{
    if(!_searchResults){
        _searchResults = [NSArray new];
    }
    return _searchResults;
}

- (NSMutableArray*)allItems{
    if(!_allItems){
        _allItems = [NSMutableArray new];
    }
    return _allItems;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
