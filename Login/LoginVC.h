//
//  LoginVC.h
//  GUO
//
//  Created by mac on 04/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardController.h"
@interface LoginVC : UIViewController
{
    
}
@property(strong,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *aScrollView;
@property(strong,nonatomic) IBOutlet UITextField *txtUname,*txtPwd;
@property(strong,nonatomic) IBOutlet UIButton *btnLogin,*btnForgotPwd,*btnRegister;
@property(strong,nonatomic) IBOutlet UILabel *lblOr;
-(IBAction)onclick_register:(id)sender;
-(IBAction)onclick_forgotpwd:(id)sender;
-(IBAction)onclick_login:(id)sender;
    
@property(strong,nonatomic) IBOutlet UILabel *lblSlogan;

@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailDividerLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLbl;
@property (weak, nonatomic) IBOutlet UILabel *passwordDividerLbl;

@end
