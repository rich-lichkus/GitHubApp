//
//  CKTopVC.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKTopVC.h"
#import "PCGitHubGraphics.h"
#import "CKOAuthController.h"

@interface CKTopVC() <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray *allItems;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tblDisplayItems;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbiMenu;
@property (weak, nonatomic) IBOutlet UISearchBar *srcSearchBar;

@end

@implementation CKTopVC

#pragma mark - View

- (void)viewDidLoad {
    
    NSLog(@"topvc loaded");
    
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
}

#pragma mark - Search

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchString];
    self.searchResults = [[self.allItems filteredArrayUsingPredicate:predicate] mutableCopy];
    
    return YES;
}

#pragma mark - Methods

-(void)setAllItemsArray:(NSMutableArray *)items{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.allItems = items;
        [self.tblDisplayItems reloadData];
    }];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return self.searchResults.count;
    } else {
        return self.allItems.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
      /// Interesting 
      Symptoms:  Push segue was not showing
      Situation: Search display controller with view containing a tableview
      Fix:       in dequeue method replaced tableview for self.tblDisplayItems
    */
    UITableViewCell *cell = [self.tblDisplayItems dequeueReusableCellWithIdentifier:@"displayResult" forIndexPath:indexPath];
    
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        cell.textLabel.text = self.searchResults[indexPath.row];
    } else {
        cell.textLabel.text = [self.allItems[indexPath.row] objectForKey:@"name"];
    }
    
    return cell;
}

#pragma mark - Lazy

- (NSMutableArray*)searchResults{
    if(!_searchResults){
        _searchResults = [NSMutableArray new];
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
