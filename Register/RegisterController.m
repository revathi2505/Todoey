//
//  RegisterController.m
//  GUO
//
//  Created by mac on 05/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import "RegisterController.h"
#import "ALChatManager.h"

@interface RegisterController ()<UITextFieldDelegate>

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UTILS setUserLanguageOnServer];

    [self initialization];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - Initialization of Data
-(void)initialization
{
    
    self.view.backgroundColor = view_BGColor;
//    "edt_firstname" = "First name";///////////////
//    "edt_lastname" = "Last name";///////////////
//    "edt_email" = "Email";///////////////
//    "btn_register" = "Register";///////////////
//    "txt_login_now" = "Have an account? Login Now";///////////////
//    [Utils SetTextFieldProperties:self.txtFullName placeholder_txt:NSLocalizedString(@"txt_name_title", nil)];
//    [Utils SetTextFieldProperties:self.txtLname placeholder_txt:NSLocalizedString(@"edt_lastname", nil)];
//    [Utils SetTextFieldProperties:self.txtUname placeholder_txt:NSLocalizedString(@"txt_username", nil)];
//    [Utils SetTextFieldProperties:self.txtEmail placeholder_txt:NSLocalizedString(@"txt_email_title", nil)];
//    [Utils SetTextFieldProperties:self.txtPwd placeholder_txt:NSLocalizedString(@"txt_password", nil)];

    
//    [Utils SetButtonProperties:self.btnReg txt:NSLocalizedString(@"btn_registration", nil)];
//
//    [self.btnBacktoLogin setTitle:NSLocalizedString(@"txt_login_now", nil) forState:UIControlStateNormal];
//    self.aScrollView.contentSize= CGSizeMake(Screen_Width, CGRectGetMaxY(self.btnReg.frame) + 50);
//    self.lblSlogan.text = NSLocalizedString(@"guo_msg", nil);
//    self.lblSlogan.font = [UIFont fontWithName:Font_Medium size:slogan_font_size];
//    [self.btnBacktoLogin.titleLabel setFont:[UIFont fontWithName:Font_regular size:btn_font_size]];
    
    self.txtEmail.delegate = self;
    self.txtUname.delegate = self;
    self.txtPwd.delegate = self;
    self.signUpCnfPasswordTF.delegate = self;
    
    self.btnReg.clipsToBounds = YES;
    self.btnReg.layer.cornerRadius = self.btnReg.bounds.size.height / 2;


}

#pragma textfield arguments

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.txtEmail){
        [self.signUpEmailLbl setTextColor:[UIColor redColor]];
        self.signUpEmailDividerLbl.backgroundColor = [UIColor redColor];
        [self.signUpNameLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpNameDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpPasswordLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpPasswordDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpCnfPasswordLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpCnfPasswordDividerLbl.backgroundColor = [UIColor darkGrayColor];
    }else if(textField == self.txtUname){
        [self.signUpEmailLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpEmailDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpNameLbl setTextColor:[UIColor redColor]];
        self.signUpNameDividerLbl.backgroundColor = [UIColor redColor];
        [self.signUpPasswordLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpPasswordDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpCnfPasswordLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpCnfPasswordDividerLbl.backgroundColor = [UIColor darkGrayColor];
    }else if(textField == self.txtPwd){
        [self.signUpEmailLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpEmailDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpNameLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpNameDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpPasswordLbl setTextColor:[UIColor redColor]];
        self.signUpPasswordDividerLbl.backgroundColor = [UIColor redColor];
        [self.signUpCnfPasswordLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpCnfPasswordDividerLbl.backgroundColor = [UIColor darkGrayColor];
    }else if(textField == self.signUpCnfPasswordTF){
        [self.signUpEmailLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpEmailDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpNameLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpNameDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpPasswordLbl setTextColor:[UIColor darkGrayColor]];
        self.signUpPasswordDividerLbl.backgroundColor = [UIColor darkGrayColor];
        [self.signUpCnfPasswordLbl setTextColor:[UIColor redColor]];
        self.signUpCnfPasswordDividerLbl.backgroundColor = [UIColor redColor];
    }
}

#pragma mark - Button Click
-(IBAction)onclick_register:(id)sender
{
    if(![self validation])
    {
        
        if (![UTILS checkIntenetShowError]) {
            return;
        }
        
        //        DashboardController *CommonDocumentControllerNav = [(AppObj).monika_storyboard  instantiateViewControllerWithIdentifier:@"DashboardController"];
        //        [self.navigationController pushViewController:CommonDocumentControllerNav animated:YES];
        
//        get=signup&amp;email=chtnghgr8@gmail.com&amp;first_name=chetan&amp;last_name=ghagre&amp;username=chetanghagre&amp;password=chetan2006&amp;query=1234
        NSDictionary *params = @{
                                 @"get":API_SIGNUP,
                                 @"email":[Utils RemoveWhiteSpaceFromText:self.txtEmail.text],
//                                 @"first_name":[Utils RemoveWhiteSpaceFromText:self.txtFname.text],
//                                 @"last_name":[Utils RemoveWhiteSpaceFromText:self.txtLname.text],
                                 @"username":[Utils RemoveWhiteSpaceFromText:self.txtUname.text],
                                 @"password":[Utils RemoveWhiteSpaceFromText:self.txtPwd.text]
                                 };
        
        [UTILS ShowProgress];
        [REMOTE_API CallPOSTWebServiceWithParam:API_SIGNUP params:params sBlock:^(id responseObject) {
            
            UserModel *loginModel = responseObject;
//            NSLog(@"%@",UTILS.currentUser.userId);
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
        }
        else
        {
            NSLog(@"Error in Applozic registration : %@",error.description);
        }
        
        [Utils HideProgress];
    }];
}

-(IBAction)onclick_back_to_login:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onclick_choose_gender:(id)sender
{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"select_gender", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:[[NSLocalizedString(@"message_dia_cancel", nil) capitalizedString] capitalizedString] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"male", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        genderStr = @"Male";

        self.txtGender.text = NSLocalizedString(@"male", nil);
        // Male button tapped.
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"female", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.txtGender.text = NSLocalizedString(@"female", nil);
        // Female button tapped.
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];

    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
#pragma mark- validation function
-(BOOL)validation
{
    NSString *str=@"";
    
//    if([Utils RemoveWhiteSpaceFromText:self.txtFullName.text].length==0)
//    {
//        str=[NSString stringWithFormat:@"%@",NSLocalizedString(@"Please Enter Full Name", nil)];
//    }
//    if([Utils RemoveWhiteSpaceFromText:self.txtLname.text].length==0)
//    {
//        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Last Name", nil)];
//    }
    if([Utils RemoveWhiteSpaceFromText:self.txtUname.text].length==0)
    {
        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Username", nil)];
    }

//    if([Utils RemoveWhiteSpaceFromText:self.txtEmail.text].length==0)
//    {
//        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Email", nil)];
//    }
//    else  if(![Utils EmailVerification:[Utils RemoveWhiteSpaceFromText:self.txtEmail.text]])
//    {
//        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Valid Email", nil)];
//    }
    if([Utils RemoveWhiteSpaceFromText:self.txtPwd.text].length==0)
    {
        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Enter Password", nil)];
    }
    else if (!([Utils RemoveWhiteSpaceFromText:self.txtPwd.text].length >=6 && [Utils RemoveWhiteSpaceFromText:self.txtPwd.text].length <= 12))
    {
        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Password length must be of 6-12", nil)];
    }
//    if(genderStr.length == 0)
//    {
//        str=[NSString stringWithFormat:@"%@\n%@",str,NSLocalizedString(@"Please Select Gender", nil)];
//    }
    
    
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
