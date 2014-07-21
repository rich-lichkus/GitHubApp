//
//  CKRootVC.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKRootVC.h"
#import "CKTopVC.h"
#import "CKMenuTableViewCell.h"
#import "PCGitHubGraphics.h"
#import "CKConstants.h"
#import "CKAppDelegate.h"
#import "CKOAuthController.h"

#define CELL_SEPARATOR_HEIGHT 1
#define PERCENTAGE_VIEW_WIDTH .70
#define TEXTFIELD_HEIGHT 40
#define UIBUTTON_HEIGHT 40
#define TEXTFIELD_PADDING 10

@interface CKRootVC () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CKTopVCDelegate, UITextFieldDelegate, CKOAuthControllerDataDelegate>

@property (strong, nonatomic) NSMutableDictionary *repoDictionary;
@property (weak, nonatomic) CKAppDelegate *appDelegate;
@property (weak, nonatomic) CKOAuthController *oAuthController;
@property (strong, nonatomic) CKTopVC *topVC;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) NSArray *menuImages;
@property (nonatomic, getter = isRightMenuOpen) BOOL rightMenuOpen;
@property (nonatomic, getter = isLeftMenuOpen) BOOL leftMenuOpen;

@property (strong, nonatomic) UIView *uivTopView;
@property (strong, nonatomic) UIButton *btnGitHub;
@property (strong, nonatomic) UITextField *txtUsername;
@property (strong, nonatomic) UITextField *txtPassword;

@property (strong, nonatomic) UIView *uivBottomView;
@property (strong, nonatomic) UIButton *btnLogin;

@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

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
    
    // OAuthController
    self.appDelegate = (CKAppDelegate *)[UIApplication sharedApplication].delegate;
    self.oAuthController = self.appDelegate.oauthController;
    self.oAuthController.dataDelegate = self;
}

-(void)configureTableView{
    self.tblMenu.delegate = self;
    self.tblMenu.dataSource = self;
}

-(void)configureTopVC{
//    [self addChildViewController:self.topVC];
//    [self.topVC didMoveToParentViewController:self];
//    [self.view addSubview:self.topVC.view];
    
    [self addChildViewController:self.navController];
    [self.navController didMoveToParentViewController:self];
    [self.view addSubview:self.navController.view];
    ((CKTopVC*)self.navController.viewControllers[0]).delegate = self;
}

-(void)configureGestureRecognizer{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecieved:)];
    
    panGesture.minimumNumberOfTouches =1;
    panGesture.maximumNumberOfTouches =1;
    panGesture.delegate = self;
    
    [self.topVC.view addGestureRecognizer:panGesture];
}

-(void)configureAnimations{
    self.rightMenuOpen = NO;
    self.leftMenuOpen = NO;
}

#pragma mark - Target Actions

-(void)pressedLogin:(id)sender{
    [self.txtPassword resignFirstResponder];
    if([self.txtUsername.text isEqualToString: @"Richard"] && [self.txtPassword.text isEqualToString:@"admin"]){
        [self lockScreen:NO];
    }
}

-(void)pressedGitHubLogin:(id)sender{
    [self.oAuthController authenticateUserWithWebService:kGitHub];
//    [self.oAuthController getWeatherForCity:@"London" andState:@"uk"];
//    [self.oAuthController get:1 catsWithFormat:@"jpg"];
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
    if(indexPath.row ==1){
        return NO;
    } else {
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 5){
        [self lockScreen:YES];
    }
}

#pragma mark - Gesture Recognizer

-(void)panGestureRecieved:(id)sender{

    // Filter Pan Gestures to detect horizontal sliding
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)sender;
    
    CGPoint translation = [panGesture translationInView:self.topVC.view];
    CGPoint touchPoint = [panGesture locationInView:self.topVC.view];
    
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

-(void)lockScreen:(BOOL)lock{
    int halfScreen = self.view.frame.size.height*.5;
    int dy = lock ? halfScreen : -halfScreen;

    [UIView animateWithDuration:.5 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.702 alpha:1.000];
        self.uivTopView.frame = CGRectOffset(self.uivTopView.frame, 0, dy);
        self.uivBottomView.frame = CGRectOffset(self.uivBottomView.frame, 0, -dy);
    } completion:^(BOOL finished) {
        if(lock){
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
    if(flag){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self lockScreen:!flag];
        }];
    }
}

-(void)didDownloadRepos:(NSMutableDictionary *)repoDictionary{
    
    [((CKTopVC*)self.navController.viewControllers[0]) setAllItemsArray: [repoDictionary mutableCopy]];
}

#pragma mark - Lazy Loading

//-(CKTopVC*)topVC{
//    if(!_topVC){
//        _topVC = [self.storyboard instantiateViewControllerWithIdentifier:@"topVC"];
//        _topVC.view.frame = self.view.frame;
//    }
//    return _topVC;
//}

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
