//
//  RegisterController.h
//  GUO
//
//  Created by mac on 05/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardController.h"
@interface RegisterController : UIViewController
{
    NSString *genderStr;
}
@property(strong,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *aScrollView;
@property(strong,nonatomic) IBOutlet UITextField *txtFullName,*txtUname,*txtEmail,*txtPwd,*txtGender;
@property(strong,nonatomic) IBOutlet UIButton *btnReg,*btnBacktoLogin;
@property(strong,nonatomic) IBOutlet UIImageView *Imgdown;

-(IBAction)onclick_choose_gender:(id)sender;
-(IBAction)onclick_back_to_login:(id)sender;

@property(strong,nonatomic) IBOutlet UILabel *lblSlogan;


@property (weak, nonatomic) IBOutlet UILabel *signUpEmailLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpEmailDividerLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpNameDividerLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpPasswordLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpPasswordDividerLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpCnfPasswordLbl;
@property (weak, nonatomic) IBOutlet UILabel *signUpCnfPasswordDividerLbl;
@property (weak, nonatomic) IBOutlet UITextField *signUpCnfPasswordTF;

@end
