//
//  LoginVC.m
//  GUO
//
//  Created by mac on 04/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import "LoginVC.h"
#import <Applozic/Applozic.h>
#import "ALChatManager.h"


@interface LoginVC ()<UITextFieldDelegate>

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialization];
    
    
    [UTILS setUserLanguageOnServer];
   
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - Initialization of Data
-(void)initialization
{
    
    //self.txtUname.text = @"monika_bq";
   // self.txtPwd.text = @"test1234";
   // self.txtUname.text = @"shivkant";
    //self.txtPwd.text = @"tiwari";
    
//    self.txtUname.text = @"chetan_ghagre";
//    self.txtPwd.text = @"chetan2006";
//    self.txtUname.text = @"shivkant55";
//    self.txtPwd.text = @"123456";

  //  self.txtUname.text = @"pawanramteke";
 //   self.txtPwd.text = @"123456";

//    self.txtUname.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.view.backgroundColor = view_BGColor;
//
//    [Utils SetTextFieldProperties:self.txtUname placeholder_txt:NSLocalizedString(@"txt_username", nil)];
//    [Utils SetTextFieldProperties:self.txtPwd placeholder_txt:NSLocalizedString(@"txt_password", nil)];
//    [Utils SetButtonProperties:self.btnLogin txt:NSLocalizedString(@"btn_login", nil)];
//    [self.btnForgotPwd setTitle:NSLocalizedString(@"txt_forgot_password", nil) forState:UIControlStateNormal];
//    [self.btnRegister setTitle:NSLocalizedString(@"txt_register_now", nil) forState:UIControlStateNormal];

   // self.lblOr.textColor = header_color;
//    self.lblOr.textColor = [UIColor blackColor];
    
    self.txtUname.delegate = self;
    self.txtPwd.delegate = self;
    
    CGFloat lbl_size = 30;
    
    
    self.lblOr.frame = CGRectMake(Screen_Width/2 - lbl_size/2, self.lblOr.frame.origin.y, lbl_size, lbl_size);
    [Utils SetRoundedCorner:self.lblOr];


    CGFloat sep_space =6;

    CGFloat sep_width = CGRectGetMinX(self.lblOr.frame) -  self.txtUname.frame.origin.x - sep_space;
   
    [Utils DrawLine:CGRectMake(self.txtUname.frame.origin.x, CGRectGetMinY(self.lblOr.frame)+(self.lblOr.frame.size.height/2) - (separator_height/2), sep_width, separator_height) view:self.aScrollView color:[UIColor whiteColor]];
    [Utils DrawLine:CGRectMake(CGRectGetMaxX(self.lblOr.frame) + sep_space, CGRectGetMinY(self.lblOr.frame)+(self.lblOr.frame.size.height/2) - (separator_height/2), sep_width, separator_height) view:self.aScrollView color:[UIColor whiteColor]];

//    self.lblSlogan.text = NSLocalizedString(@"guo_msg", nil);
//    self.lblOr.text = NSLocalizedString(@"txt_or", nil);
    
//    self.lblSlogan.font = [UIFont fontWithName:Font_Medium size:slogan_font_size];
//    [self.btnForgotPwd.titleLabel setFont:[UIFont fontWithName:Font_regular size:button_font_size]];
//    [self.btnRegister.titleLabel setFont:[UIFont fontWithName:Font_regular size:button_font_size]];
    
    self.btnLogin.clipsToBounds = YES;
    self.btnLogin.layer.cornerRadius = self.btnLogin.bounds.size.height / 2;
}

#pragma textfield arguments

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.txtUname){
        [self.emailLbl setTextColor:[UIColor redColor]];
        self.emailDividerLabel.backgroundColor = [UIColor redColor];
        [self.passwordLbl setTextColor:[UIColor darkGrayColor]];
        self.passwordDividerLbl.backgroundColor = [UIColor darkGrayColor];
    }else if(textField == self.txtPwd){
        [self.passwordLbl setTextColor:[UIColor redColor]];
        self.passwordDividerLbl.backgroundColor = [UIColor redColor];
        [self.emailLbl setTextColor:[UIColor darkGrayColor]];
        self.emailDividerLabel.backgroundColor = [UIColor darkGrayColor];
    }
}

#pragma mark - Button Click
-(IBAction)onclick_back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onclick_login:(id)sender
{
    if(![self validation])
    {
        
        if (![UTILS checkIntenetShowError]) {
            return;
        }
        
        NSDictionary *params = @{
                                 @"get":API_LOGIN,
                                 @"username":_txtUname.text,
                                 @"password":_txtPwd.text
                            
                                 };
       
        [UTILS ShowProgress];
        [REMOTE_API CallPOSTWebServiceWithParam:API_LOGIN params:params sBlock:^(id responseObject) {
            
            UserModel *loginModel = responseObject;
            UTILS.currentUser = loginModel;

            
            
            [self loginAplozic:loginModel];

        } fBlock:^(NSString *customErrorMsg, NSInteger errorCode) {
            [Utils HideProgress];
            [CustomAlertView showAlert:@"" withMessage:customErrorMsg];
        }];
       
        
    }
}

-(void)loginAplozic:(UserModel*)loginModel
{
    
    
    ALUser *alUser = [[ALUser alloc] initWithUserId:UTILS.currentUser.userId password:UTILS.currentUser.userName email:UTILS.currentUser.userEmail andDisplayName:UTILS.currentUser.userName];
    
    [alUser setAuthenticationTypeId:APPLOZIC];
    
    [ALUserDefaultsHandler setUserAuthenticationTypeId:APPLOZIC];
    
    //Saving the details
    [ALUserDefaultsHandler setUserId:alUser.userId];
    [ALUserDefaultsHandler setEmailId:alUser.email];
    [ALUserDefaultsHandler setDisplayName:alUser.displayName];
    [[NSUserDefaults standardUserDefaults] setValue:UTILS.currentUser.userPicture forKey:@"picture"];
    
    
    
    //Registering or Loging in the User
    ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:APPLICATION_ID];
    
    [chatManager registerUserWithCompletion:alUser withHandler:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if (!error)
        {
            //Applozic registration successful
            Utils.getSharedInstance.currentUser = loginModel;
            [GUOSettings setIsLogin:loginModel];
            [AppObj loadNewsSlidingMenu:YES];
            
            [self updateApplozicProfilePic];
            
        }
        else
        {
            NSLog(@"Error in Applozic registration : %@",error.description);
        }
        
         [Utils HideProgress];
    }];
}


-(void)updateApplozicProfilePic
{
    NSLog(@"UTILS.currentUser.userPicture = %@",UTILS.currentUser.userPicture);
    ALUserService *userService = [ALUserService new];
    [userService updateUserDisplayName:UTILS.currentUser.userName
                          andUserImage:[[Utils getThumbUrl:UTILS.currentUser.userPicture] absoluteString]
                            userStatus:@""
                        withCompletion:^(id theJson, NSError *error) {
                            
                            NSLog(@"Applozic pic updated successfully = %@",theJson);
                            
                        }];
    
}


-(IBAction)onclick_register:(id)sender
{
    
}
-(IBAction)onclick_forgotpwd:(id)sender
{
    
}
#pragma mark- validation function
-(BOOL)validation
{
    NSString *str=@"";
    
    
    if([Utils RemoveWhiteSpaceFromText:self.txtUname.text].length==0)
    {
        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Username", nil)];
    }
    if([Utils RemoveWhiteSpaceFromText:self.txtPwd.text].length==0)
    {
        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Password", nil)];
    }
    
    
    
    if([str isEqualToString:@""])
    {
        return false;
    }
    else
    {
        
        if([str hasPrefix:@"\n"])
        {
            str=[str substringFromIndex:1];
        }
        [Utils ShowAlert:str];
        
        return true;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
