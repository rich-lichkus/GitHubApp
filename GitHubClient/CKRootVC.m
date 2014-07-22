//
//  CKRootVC.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKRootVC.h"

#import "CKAppDelegate.h"
#import "CKTopVC.h"
#import "CKMenuTableViewCell.h"
#import "PCGitHubGraphics.h"
#import "CKOAuthController.h"
#import "CKGitHubNetworkController.h"

#define CELL_SEPARATOR_HEIGHT 1
#define PERCENTAGE_VIEW_WIDTH .70
#define TEXTFIELD_HEIGHT 40
#define UIBUTTON_HEIGHT 40
#define TEXTFIELD_PADDING 10

@interface CKRootVC () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CKTopVCDelegate, UITextFieldDelegate, CKOAuthControllerDataDelegate>

@property (weak, nonatomic) CKAppDelegate *weak_appDelegate;
@property (weak, nonatomic) CKOAuthController *weak_oAuthController;    // Strong ref in app del
@property (weak, nonatomic) CKGitHubNetworkController *weak_gitHubNC;   // Strong ref in app del
@property (weak, nonatomic) CKTopVC *weak_topVC;                        // Strong ref in nav controller

@property (strong, nonatomic) NSMutableDictionary *repoDictionary;

@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) NSArray *menuImages;
@property (nonatomic, getter = isRightMenuOpen) BOOL rightMenuOpen;
@property (nonatomic, getter = isLeftMenuOpen) BOOL leftMenuOpen;

@property (strong, nonatomic) UINavigationController *navController;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (strong, nonatomic) UIView *uivTopView;
@property (strong, nonatomic) UIButton *btnGitHub;
@property (strong, nonatomic) UITextField *txtUsername;
@property (strong, nonatomic) UITextField *txtPassword;

@property (strong, nonatomic) UIView *uivBottomView;
@property (strong, nonatomic) UIButton *btnLogin;

@end

@implementation CKRootVC

#pragma mark - Init

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        self.menuTitles = @[@"Me",@"",@"Repos", @"Followers", @"Following", @"Logout"];
        self.menuImages = @[[PCGitHubGraphics imageOfUser], @"",[PCGitHubGraphics imageOfRepo], [PCGitHubGraphics imageOfUser], [PCGitHubGraphics imageOfUser], [PCGitHubGraphics imageOfLocked]];
    }
    return self;
}

#pragma mark - View Did Load 

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self configureTopVC];
    
    [self configureGestureRecognizer];
    
    [self configureAnimations];
    
    [self configureLockScreen];
}

#pragma mark - Configuration

-(void)configureLockScreen{
    
    float halfScreen = self.view.frame.size.height*.5;
    float uiElementWidth = self.view.frame.size.width*.75;
    
    // Lock Screen Top View
    self.uivTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                              self.view.frame.size.width,
                                                              halfScreen)];
    self.uivTopView.backgroundColor = [UIColor colorWithWhite:0.902 alpha:1.000];
    
    self.btnGitHub = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-(uiElementWidth*.5),
                                                               self.uivTopView.frame.size.height - (4*TEXTFIELD_HEIGHT+4*TEXTFIELD_PADDING),
                                                               uiElementWidth,
                                                                TEXTFIELD_HEIGHT)];
    [self.btnGitHub setImage:[PCGitHubGraphics imageOfGitHubLogin] forState:UIControlStateNormal];
    [self.btnGitHub addTarget:self action:@selector(pressedGitHubLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    self.txtUsername = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x-(uiElementWidth*.5),
                                                                     self.uivTopView.frame.size.height - (2*TEXTFIELD_HEIGHT+2*TEXTFIELD_PADDING),
                                                                     uiElementWidth,
                                                                     TEXTFIELD_HEIGHT)];
    self.txtUsername.borderStyle = UITextBorderStyleRoundedRect;
    self.txtUsername.backgroundColor = [UIColor colorWithWhite:0.800 alpha:0.250];
    self.txtUsername.placeholder = @"Username";
    self.txtUsername.delegate = self;
    self.txtUsername.tag = kLoginUsernameTxtTag;
    
    self.txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x-(uiElementWidth*.5),
                                                                     self.uivTopView.frame.size.height - TEXTFIELD_HEIGHT - TEXTFIELD_PADDING,
                                                                     uiElementWidth,
                                                                     TEXTFIELD_HEIGHT)];
    self.txtPassword.borderStyle = UITextBorderStyleRoundedRect;
    self.txtPassword.backgroundColor = [UIColor colorWithWhite:0.800 alpha:0.250];
    self.txtPassword.placeholder = @"Password";
    self.txtPassword.delegate = self;
    self.txtPassword.tag = kLoginPasswordTxtTag;
    self.txtPassword.secureTextEntry = YES;

    [self.uivTopView addSubview:self.btnGitHub];
    [self.uivTopView addSubview:self.txtUsername];
    [self.uivTopView addSubview:self.txtPassword];
    [self.view addSubview:self.uivTopView];

    // Lock Screen Bottom View
    self.uivBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, halfScreen,
                                                                  self.view.frame.size.width, halfScreen)];
    self.uivBottomView.backgroundColor = [UIColor colorWithWhite:0.902 alpha:1.000];
    
    self.btnLogin = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-(uiElementWidth*.5), 0, uiElementWidth, UIBUTTON_HEIGHT)];
    [self.btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    self.btnLogin.enabled = NO;
    [self.btnLogin setBackgroundImage:[PCGitHubGraphics imageOfDisabledButton] forState:UIControlStateDisabled];
    [self.btnLogin setBackgroundImage:[PCGitHubGraphics imageOfEnabledButton] forState:UIControlStateNormal];
    self.btnLogin.layer.cornerRadius = 5;
    self.btnLogin.layer.masksToBounds = YES;
    [self.btnLogin addTarget:self action:@selector(pressedLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.uivBottomView addSubview:self.btnLogin];
    [self.view addSubview:self.uivBottomView];
    
    self.weak_appDelegate = (CKAppDelegate *)[UIApplication sharedApplication].delegate;
    // OAuthController
    self.weak_oAuthController = self.weak_appDelegate.oauthController;
    self.weak_oAuthController.dataDelegate = self;
    // GitHub N. Controller
    self.weak_gitHubNC = self.weak_appDelegate.gitHubNC;
    self.weak_gitHubNC.dataDelegate = self.weak_topVC;
}

-(void)configureTableView{
    self.tblMenu.delegate = self;
    self.tblMenu.dataSource = self;
}

-(void)configureTopVC{
    [self addChildViewController:self.navController];
    [self.navController didMoveToParentViewController:self];
    [self.view addSubview:self.navController.view];
    
    self.weak_topVC = ((CKTopVC*)self.navController.viewControllers[0]);
    self.weak_topVC.delegate = self;
//    [self.weak_topVC selectedMenu:kRepoMenu];
}

-(void)configureGestureRecognizer{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecieved:)];
    
    panGesture.minimumNumberOfTouches =1;
    panGesture.maximumNumberOfTouches =1;
    panGesture.delegate = self;
    
    [self.weak_topVC.view addGestureRecognizer:panGesture];
}

-(void)configureAnimations{
    self.rightMenuOpen = NO;
    self.leftMenuOpen = NO;
}

#pragma mark - Target Actions

-(void)pressedLogin:(id)sender{
    [self.txtPassword resignFirstResponder];
    if([self.txtUsername.text isEqualToString: @"Richard"] && [self.txtPassword.text isEqualToString:@"admin"]){
        [self unlockScreen:YES];
    }
}

-(void)pressedGitHubLogin:(id)sender{
    [self.weak_oAuthController authenticateUserWithWebService:kGitHub];
}
#pragma mark - TextField

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    switch (textField.tag) {
        case kLoginUsernameTxtTag: {
            
        }
            break;
        case kLoginPasswordTxtTag: {
            self.btnLogin.enabled = YES;
        }
            break;
    }
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CKMenuTableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    if(indexPath.row != 1){
        menuCell.textLabel.text = self.menuTitles[indexPath.row];
        menuCell.imageView.image = self.menuImages[indexPath.row];
        menuCell.textLabel.textColor = [UIColor whiteColor];
    }
    
    menuCell.uivSeparator = [[UIView alloc] initWithFrame:CGRectMake(menuCell.textLabel.frame.origin.x,
                                                                       menuCell.frame.size.height-CELL_SEPARATOR_HEIGHT,
                                                                       menuCell.textLabel.frame.size.width,
                                                                       CELL_SEPARATOR_HEIGHT)];
    menuCell.uivSeparator.backgroundColor = [UIColor whiteColor];
    [menuCell addSubview:menuCell.uivSeparator];
    
    return menuCell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case kBlankMenu:
        {
            return NO;
        }
            break;
        default:
        {
            return YES;
        }
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case kLogoutMenu:
        {
            [self unlockScreen:NO];
        }
            break;
    }
    
    [self.weak_topVC selectedMenu:indexPath.row];
    [self closeMenu];
}

#pragma mark - Gesture Recognizer

-(void)panGestureRecieved:(id)sender{

    // Filter Pan Gestures to detect horizontal sliding
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)sender;
    
    CGPoint translation = [panGesture translationInView:self.weak_topVC.view];
    CGPoint touchPoint = [panGesture locationInView:self.weak_topVC.view];
    
    if(touchPoint.x > 0 && touchPoint.x < 30) {         // Determine if left side bar
        NSLog(@"Left Bar");
        if(translation.x > 20 && translation.y < 10){   // Determine if drag right
            NSLog(@"Drag Right");
            if(!self.isLeftMenuOpen){
                [self openLeftMenu];
            }
        }
    }
    
    if(touchPoint.x >self.view.frame.size.width-30 && touchPoint.x < self.view.frame.size.width){
        // Determine if right side bar
        NSLog(@"Right Bar");
        if(translation.x > -20 && translation.y < 10){   // Determine if drag left
            NSLog(@"Drag Left");
            if(!self.isRightMenuOpen){
                [self openRightMenu];
            }
        }
    }
}

#pragma mark - Menu Animations

-(void)openLeftMenu{
    self.leftMenuOpen = YES;
    [UIView animateWithDuration: .3 animations:^{
        self.navController.view.frame = CGRectOffset(self.navController.view.frame,
                                             self.navController.view.frame.size.width*PERCENTAGE_VIEW_WIDTH,
                                             0);
        self.navController.view.backgroundColor = [UIColor colorWithWhite:0.702 alpha:1.000];

    } completion:^(BOOL finished) {
        
    }];
}

-(void)openRightMenu{
//    self.rightMenuOpen = YES;
//    [UIView animateWithDuration: .3 animations:^{
//        self.topVC.view.frame = CGRectOffset(self.topVC.view.frame,
//                                             -self.topVC.view.frame.size.width*PERCENTAGE_VIEW_WIDTH,
//                                             0);
//        self.topVC.view.backgroundColor = [UIColor colorWithWhite:0.702 alpha:1.000];
//    } completion:^(BOOL finished) {
//        
//    }];
}

-(void)closeMenu{
    self.rightMenuOpen = NO;
    self.leftMenuOpen = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.navController.view.frame = self.view.frame;
        self.navController.view.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)unlockScreen:(BOOL)authenticated{
    int halfScreen = self.view.frame.size.height*.5;
    int dy = authenticated ? -halfScreen : halfScreen;

    [UIView animateWithDuration:.5 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.702 alpha:1.000];
        self.uivTopView.frame = CGRectOffset(self.uivTopView.frame, 0, dy);
        self.uivBottomView.frame = CGRectOffset(self.uivBottomView.frame, 0, -dy);
    } completion:^(BOOL finished) {
        if(authenticated){
            [self closeMenu];
        }
    }];
}

#pragma mark - Delegation
-(void)menuClicked{
    NSLog(@"menuClicked");
    if(self.isLeftMenuOpen){
        [self closeMenu];
    } else {
        [self openLeftMenu];
    }
}

-(void)didDownloadImage:(UIImage *)uiimage{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //self.imgCat.image = uiimage;
        [self.uivTopView setNeedsDisplay];
    }];
//
}

-(void)didAuthenticateUser:(BOOL)flag{
    if(flag){   //authenticated
        [self.weak_gitHubNC setAccessToken:[self.weak_oAuthController gitHubAccessToken]];
        [self.weak_gitHubNC retrieveAllData];
        [self unlockScreen:flag];
    }
}

#pragma mark - Lazy Loading

-(UINavigationController*)navController{
    if(!_navController){
        _navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
        _navController.view.frame = self.view.frame;
    }
    return _navController;
}

-(NSMutableDictionary*)repoDictionary{
    if(!_repoDictionary){
        _repoDictionary = [[NSMutableDictionary alloc] init];
    }
    return  _repoDictionary;
}

#pragma mark - Memory

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
