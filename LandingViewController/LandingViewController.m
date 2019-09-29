//
//  LandingViewController.m
//  GUO
//
//  Created by Parag on 6/7/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import "LandingViewController.h"

@interface LandingViewController ()
  @property (weak, nonatomic) IBOutlet UIView *containerView;
  @property (weak, nonatomic) IBOutlet UIButton *btnEnglish;
  @property (weak, nonatomic) IBOutlet UIButton *btnChinese;
  @property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
  @property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;
  @property (weak, nonatomic) IBOutlet UIButton *btnGUO;
  @property (weak, nonatomic) IBOutlet UIButton *btnLogin;
  
@end

@implementation LandingViewController

  
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UserModel *u_model=[GUOSettings getIsLogin];
    if(u_model.userId!=nil)
    {
        Utils.getSharedInstance.currentUser = u_model;
        [AppObj loadNewsSlidingMenu:NO];
        return;
    }
    
    [self setupUIComponents];
    // Do any additional setup after loading the view.
    UILabel *headingLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    headingLable.text     = @"Welcom to GMedia";
    headingLable.textColor = [UIColor whiteColor];
    headingLable.textAlignment = NSTextAlignmentCenter;
    [headingLable setFont:[UIFont boldSystemFontOfSize:38]];
    
    UIButton *GMMediaButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headingLable.frame), 200, 60)];
    GMMediaButton.layer.masksToBounds = true;
    GMMediaButton.layer.cornerRadius = 30;
    [GMMediaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    GMMediaButton.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1.0];
    [GMMediaButton setTitle:@"GNews" forState:UIControlStateNormal];
    GMMediaButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [GMMediaButton setImage:[UIImage imageNamed:@"ic_news"] forState:UIControlStateNormal];
    [GMMediaButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0,110)];
    [GMMediaButton addTarget:self action:@selector(btnLoginTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 150, 150)];
    imageView.image        = [UIImage imageNamed:@"Image.png"];
    
    imageView.center       = CGPointMake(75, 75 + 10);
    
    headingLable.center    = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    GMMediaButton.center   = CGPointMake(self.view.bounds.size.width/2., headingLable.center.y + (headingLable.bounds.size.height / 2 + GMMediaButton.bounds.size.height / 2 + 25 ));
    
    //imageView.center       = CGPointMake(self.view.bounds.size.width/2, headingLable.center.y + (headingLable.bounds.size.height / 2 + imageView.bounds.size.height / 2 +  10 ));
    //GMMediaButton.center   = CGPointMake(self.view.bounds.size.width/2., imageView.center.y + (imageView.bounds.size.height / 2 + GMMediaButton.bounds.size.height / 2 + 10 ));
    
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    CGFloat scrollViewHeight = self.scrollView.bounds.size.height;
    
    UIImageView *img1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewWidth  , scrollViewHeight)];
    img1.image = [UIImage imageNamed:@"test"];
    img1.alpha = 0.9;
    
    UIImageView *img2 = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth, 0, scrollViewWidth, scrollViewHeight)];
    img2.image = [UIImage imageNamed:@"test2"];
    img2.alpha = 0.9;
    
    UIImageView *img3 = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth * 2 , 0, scrollViewWidth, scrollViewHeight)];
    img3.image = [UIImage imageNamed:@"test3"];
    img3.alpha = 0.9;
    
    [self.scrollView addSubview:img1];
    [self.scrollView addSubview:img2];
    [self.scrollView addSubview:img3];
    
    self.scrollView.contentSize = CGSizeMake(scrollViewWidth * 3, scrollViewHeight);
    self.scrollView.delegate    = self;
    self.pageControl.currentPage = 0;
    
    [self.view addSubview:headingLable];
    [self.view addSubview:GMMediaButton];
    [self.view addSubview:imageView];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(moveToNextPage) userInfo:nil repeats:YES];
}
  
  -(void)setupUIComponents{
    
    //self.imageViewProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.imageViewProfile.layer.borderWidth = 4.0;
    self.imageViewProfile.clipsToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = 60;
    [self.view bringSubviewToFront:self.imageViewProfile];
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 15;
    
    self.btnGUO.clipsToBounds = YES;
    self.btnGUO.layer.cornerRadius = 8;
    
    self.btnLogin.clipsToBounds = YES;
    self.btnLogin.layer.cornerRadius = 8;
    
    self.btnEnglish.clipsToBounds = YES;
    self.btnEnglish.layer.cornerRadius = 8;
    
    self.btnChinese.clipsToBounds = YES;
    self.btnChinese.layer.cornerRadius = 8;
    
    
    self.containerView.clipsToBounds = YES;
      [self ChangeControlLanguage];
      [self.btnGUO.titleLabel setFont:[UIFont fontWithName:Font_Medium size:landing_page_button]];
      [self.btnLogin.titleLabel setFont:[UIFont fontWithName:Font_Medium size:landing_page_button]];
      [self.btnEnglish.titleLabel setFont:[UIFont fontWithName:Font_Medium size:btn_font_size]];
      [self.btnChinese.titleLabel setFont:[UIFont fontWithName:Font_Medium size:btn_font_size]];
      if(iPhone5 || iPhone4)
      {
          [self.lblChangeLangTitle setFont:[UIFont fontWithName:Font_Medium size:15]];
      }
      else
      {
          [self.lblChangeLangTitle setFont:[UIFont fontWithName:Font_Medium size:20]];
      }
  }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ChangeControlLanguage
{
    if([[NSString stringWithFormat:@"%@",[GUOSettings GetLanguage]] isEqualToString:[NSString stringWithFormat:@"%@",SetEnglish]])
    {
        
        [self.btnChinese setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnEnglish setTitleColor:header_color forState:UIControlStateNormal];

    }
    else
    {
        [self.btnChinese setTitleColor:header_color forState:UIControlStateNormal];
        [self.btnEnglish setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if(self.is_came_from_sliding_menu)
    {
        [self.btnLogin setTitle:NSLocalizedString(@"post_title", nil) forState:UIControlStateNormal];

    }
    else
    {
        [self.btnLogin setTitle:NSLocalizedString(@"btn_login", nil) forState:UIControlStateNormal];
    }
    [self.btnLogin setBackgroundColor:header_color];
    [self chnageTitleLbl];
}
  -(void)chnageTitleLbl
{
    self.lblChangeLangTitle.text = NSLocalizedString(@"select_your_language", nil);

}
#pragma MArk Actions
  
- (IBAction)btnChineseTouched:(id)sender {

    [NSBundle setLanguage:SetChinese];

    [GUOSettings SetLanguage:SetChinese];
   [self.btnChinese setTitleColor:header_color forState:UIControlStateNormal];
   [self.btnEnglish setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self ChangeControlLanguage];
    [self btnLoginTouched:self];
    [self chnageTitleLbl];
    
    [UTILS setUserLanguageOnServer];

}
- (IBAction)btnEnglishTouched:(id)sender {

    [NSBundle setLanguage:SetEnglish];

    [GUOSettings SetLanguage:SetEnglish];
  [self.btnChinese setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.btnEnglish setTitleColor:header_color forState:UIControlStateNormal];
//    [self ChangeControlLanguage];
    
    [self btnLoginTouched:self];
    [self chnageTitleLbl];
    
    [UTILS setUserLanguageOnServer];

}
- (IBAction)btnGUOTouched:(id)sender {
  
}
  
- (IBAction)btnLoginTouched:(id)sender {
    
    if(!self.is_came_from_sliding_menu)
    {
        UIViewController* rootController = [(AppObj).monika_storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [(AppObj).navController pushViewController:rootController animated:YES];
        (AppObj).navController.navigationBarHidden = YES;
    }
    else
    {
        [AppObj loadNewsSlidingMenu:YES];

    }
}

- (void)moveToNextPage
{
    CGFloat pageWidth = self.view.frame.size.width;
    CGFloat maxWidth = pageWidth * 3;
    CGFloat contentOffset = self.scrollView.contentOffset.x;
    
    float slideToX = contentOffset + pageWidth;
    
    if(contentOffset + pageWidth == maxWidth){
        slideToX = 0;
    }
    
    [self.scrollView scrollRectToVisible:CGRectMake(slideToX, 0, pageWidth, self.scrollView.bounds.size.height) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGFloat currentPage = floor((scrollView.contentOffset.x - (scrollView.bounds.size.width))/(scrollView.bounds.size.width)) + 1;
    self.pageControl.currentPage = (NSInteger) currentPage;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat currentPage = floor((scrollView.contentOffset.x - (scrollView.bounds.size.width))/(scrollView.bounds.size.width)) + 1;
    self.pageControl.currentPage = (NSInteger) currentPage;
    
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
