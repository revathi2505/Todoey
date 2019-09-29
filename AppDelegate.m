//
//  AppDelegate.m
//  GUO
//
//  Created by mac on 04/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import "AppDelegate.h"
#import "AWSCore.h"
#import <Applozic/ALApplozicSettings.h>
#import <Applozic/Applozic.h>
#import "PostDetailsController.h"
#import "ALChatManager.h"

@class CustomTabVC;

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize frostedViewController;
//MARK: STATUS BAR COLOUR
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    sleep(3);
    
    
    
    // UIColor(red: 104/255, green: 122/255, blue: 137/255, alpha: 1)
    [self setStatusBarBackgroundColor:UIColor.lightGrayColor];
    // [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    
    //Set Language
    if([GUOSettings GetLanguage] == nil)
    {
        [GUOSettings SetLanguage:SetEnglish];
        [NSBundle setLanguage:SetEnglish];
    }
    else
    {
        
        if([[GUOSettings GetLanguage] isEqualToString:SetEnglish])
        {
            [NSBundle setLanguage:SetEnglish];
            
            [GUOSettings SetLanguage:SetEnglish];
        }
        else
        {
            [NSBundle setLanguage:SetChinese];
            
            [GUOSettings SetLanguage:SetChinese];
            
        }
        
        
    }
    
    // Override point for customization after application launch.
    self.monika_storyboard = [UIStoryboard storyboardWithName:Monika_storyboard
                                                       bundle: nil];
    
    
    self.pawan_storyboard = [UIStoryboard storyboardWithName:PAWAN_storyboard
                                                      bundle: nil];
    
    
    [self configureAWS];
    
    [UTILS setUserLanguageOnServer];
    
    //    BOOL is_login = true;
    //    if (!is_login)
    //    {
    //        self.window.rootViewController = [(AppObj).monika_storyboard instantiateInitialViewController];
    //    }
    //    else
    //    {
    //      [self displayLandingVC];
    ////        UIViewController* rootController = [(AppObj).monika_storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    ////        self.navController=[[UINavigationController alloc] initWithRootViewController:rootController];
    ////        self.navController.navigationBarHidden=YES;
    ////
    ////        self.window.rootViewController = self.navController;
    //    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIViewController* landingVC = [(AppObj).monika_storyboard instantiateViewControllerWithIdentifier:@"LandingViewController"];
    self.navController=[[UINavigationController alloc] initWithRootViewController:landingVC];
    self.navController.navigationBarHidden=YES;
    
    self.window.rootViewController=self.navController;
    [self.window makeKeyAndVisible];
    
    [self registerForPushNotification:application];
    [self registerAppLozic:launchOptions];

    [self setNavigationTheme];
    (AppObj).postView = [[PostController alloc]init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProfileShowFromChat:) name:@"chat_open_profile" object:nil];
    
    
    return YES;
}

-(void)registerAppLozic:(NSDictionary *)launchOptions
{
    // checks wheather app version is updated/changed then makes server call setting VERSION_CODE
    [ALRegisterUserClientService isAppUpdated];
    
    // Register for Applozic notification tap actions and network change notifications
    ALAppLocalNotifications *localNotification = [ALAppLocalNotifications appLocalNotificationHandler];
    [localNotification dataConnectionNotificationHandler];
    
    // Override point for customization after application launch.
    NSLog(@"launchOptions: %@", launchOptions);
    if (launchOptions != nil) {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil) {
            NSLog(@"Launched from push notification: %@", dictionary);
            ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
            BOOL applozicProcessed = [pushNotificationService processPushNotification:dictionary updateUI:[NSNumber numberWithInt:APP_STATE_INACTIVE]];
            
            //IF not a appplozic notification, process it
            if (!applozicProcessed) {
                //Note: notification for app
            }
        }
    }
}


-(void)setNavigationTheme
{
    [ALApplozicSettings setColorForNavigation:header_color];
    [ALApplozicSettings setStatusBarBGColor:header_color];
    
    
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    
    
    /* if(@available(iOS 11, *)) {
     //[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];
     // [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateHighlighted];
     
     
     [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-60, -60) forBarMetrics:UIBarMetricsDefault];
     
     } else {
     [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-60, -60) forBarMetrics:UIBarMetricsDefault];
     }
     
     UIImage *back = [[UIImage imageNamed:@"back_Img"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     navigationBar.backIndicatorImage = back;
     navigationBar.backIndicatorTransitionMaskImage = back;
     
     */
}
-(void)configureAWS
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:AWS_POOL_ID];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    configuration.maxRetryCount = 5;
    //configuration.timeoutIntervalForRequest = 15*60;
    //configuration.timeoutIntervalForResource = 15*60;
    configuration.allowsCellularAccess = YES;
    
    
    
    AWSS3TransferUtilityConfiguration *util = [AWSS3TransferUtilityConfiguration new];
    util.retryLimit = 5;
    //util.timeoutIntervalForResource = 15*60;
    //util.multiPartConcurrencyLimit = [NSNumber numberWithInteger:10];
    [util setBucket:S3_bUCKET_NAME];
    [util setAccelerateModeEnabled:YES];
    
    
    
    [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:configuration transferUtilityConfiguration:util forKey:APP_AWS_ACCELERATION_KEY];
    
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}


-(void)registerForPushNotification:(UIApplication *)application
{
#if !TARGET_IPHONE_SIMULATOR
    //Device token
    //Changed by Nirav
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
#else
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil]];
    [application registerForRemoteNotifications];
#endif
}

//Changed by Nirav
#pragma mark - UNUserNotificationCenter Delegate Methods Here....

//Called when a notification is delivered to a foreground app.

/*- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
 NSLog(@"User Info : %@", notification.request.content.userInfo);
 
 completionHandler((UNNotificationPresentationOptions) UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge);
 }
 
 //Called to let your app know which action was selected by the user for a given notification.
 
 - (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
 NSLog(@"User Info : %@", response.notification.request.content.userInfo);
 
 
 
 completionHandler();
 }
 */
#pragma mark - Device token
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *dToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dToken = [dToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"dToken = %@",dToken);
    
    // [CustomAlertView showAlert:@"" withMessage:dToken];
    
    // [Utility_Shared_Instance writeStringUserPreference:KDEVICE_TOKEN value:dToken];
    [GUOSettings saveDeviceToken:dToken];
    
    if (![[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:dToken]) {
        ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
        [registerUserClientService updateApnDeviceTokenWithCompletion
         :dToken withCompletion:^(ALRegistrationResponse
                                  *rResponse, NSError *error) {
            
            if (error) {
                NSLog(@"%@",error);
                return;
            }
            NSLog(@"Registration response%@", rResponse);
        }];
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
    [pushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
    [self handleOurAppNotifications:userInfo application:application];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    NSLog(@"Received notification Completion: %@", userInfo);
    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
    [pushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    [self handleOurAppNotifications:userInfo application:application];
    
    
}

-(void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error %@",err);
}


#pragma mark- Set sliding menu
-(void)LoadSlidingMenu:(BOOL)Anim_val
{
    SlideMenuVC *slideMenuVC = [[SlideMenuVC alloc] init];
    
    
    DashboardController *dashVC = [(AppObj).monika_storyboard  instantiateViewControllerWithIdentifier:@"DashboardController"];
    
    dashVC.from_login_screen=Anim_val;
    UINavigationController *tempNav = [[UINavigationController alloc] initWithRootViewController:dashVC];
    tempNav.navigationBarHidden=YES;
    
    frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tempNav menuViewController:slideMenuVC];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleDark;
    frostedViewController.liveBlur = YES;
    frostedViewController.delegate = self;
    frostedViewController.backgroundFadeAmount = 0.8;
    UINavigationController *tempNav1 = [[UINavigationController alloc] initWithRootViewController:frostedViewController];
    
    frostedViewController.navigationController.navigationBarHidden = YES;
    
    
    self.window.rootViewController = tempNav1;
    //[self.navController pushViewController:frostedViewController animated:Anim_val];
}
-(void)loadNewsSlidingMenu:(BOOL)Anim_val
{
    SlideMenuVC *slideMenuVC = [[SlideMenuVC alloc] init];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"News"
                                                             bundle: nil];
    
    CustomTabVC *customTabVC = [mainStoryboard  instantiateViewControllerWithIdentifier:@"CUSTOM_TAB"];
    
    UINavigationController *tempNav = [[UINavigationController alloc] initWithRootViewController:customTabVC];
    tempNav.navigationBarHidden=YES;
    
    frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tempNav menuViewController:slideMenuVC];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleDark;
    frostedViewController.liveBlur = YES;
    frostedViewController.delegate = self;
    frostedViewController.backgroundFadeAmount = 0.8;
    UINavigationController *tempNav1 = [[UINavigationController alloc] initWithRootViewController:frostedViewController];
    
    frostedViewController.navigationController.navigationBarHidden = YES;
    
    
    self.window.rootViewController = tempNav1;
    //[self.navController pushViewController:frostedViewController animated:Anim_val];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService disconnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_BACKGROUND" object:nil];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService connect];
    [ALPushNotificationService applicationEntersForeground];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_FOREGROUND" object:nil];
    
    
    [self handleShareExtention];
    
}


-(void)handleShareExtention
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.message.extension1"];
    NSDictionary *imgDic = [defaults objectForKey:@"guo_ext"];
    
    // [CustomAlertView showAlert:@"" withMessage:@"Test extention delegate"];
    
    if (imgDic) {
        
        
        ALMessage * theMessage = [ALMessage new];
        
        NSData *imgData = imgDic[@"imgData"];
        NSString *message = imgDic[@"message"];
        NSString *imgPath = imgDic[@"imagePath"];
        
        
        
        if (imgData) {
            
            NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *tempPath = [NSString stringWithFormat:@"%@/%@",docDirPath,[imgPath lastPathComponent]];//[NSTemporaryDirectory() stringByAppendingString:@"tempImage.PNG"];
            [imgData writeToFile:tempPath atomically:YES];
            
            theMessage.imageFilePath = tempPath;
            theMessage.contentType = 1;
            
        }
        
        theMessage.type = @"5";
        theMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
        theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString];
        theMessage.message = message?message:@"";
        theMessage.sendToDevice = NO;
        theMessage.shared = NO;
        theMessage.fileMeta = nil;
        theMessage.storeOnDevice = NO;
        theMessage.key = [[NSUUID UUID] UUIDString];
        theMessage.delivered = NO;
        theMessage.fileMetaKey = nil;
        theMessage.source = SOURCE_IOS;
        
        //    You have to pass the image file path, content type and message text above. For example: content type for images is 1. Then call the below method:
        
        ALChatManager* chatmanager = [[ALChatManager alloc] init];
        [chatmanager launchContactScreenWithMessage:theMessage andFromViewController:[UTILS topMostControllerNormal]];
        
        //reset the defualts
        [defaults setObject:nil forKey:@"guo_ext"];
        [defaults synchronize];
        
    }
    
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[ALDBHandler sharedInstance] saveContext];
}
-(void)GetCountAPI:(NSString*)userId is_show_progress:(BOOL)is_show_progress
{
    
    NSDictionary *params = @{
        @"get":API_GET_COUNT,
        @"user_id":userId
    };
    if(!is_show_progress)
    {
        // [UTILS ShowProgress];
    }
    [REMOTE_API CallPOSTWebServiceWithParam:API_GET_COUNT params:params sBlock:^(id responseObject) {
        
        //self.app_count_model = [[CountModel alloc]init];
        self.app_count_model = responseObject;
        
        // [Utils HideProgress];
    } fBlock:^(NSString *customErrorMsg, NSInteger errorCode) {
        [Utils HideProgress];
        //[CustomAlertView showAlert:@"" withMessage:customErrorMsg];
    }];
    
}

-(void)handleOurAppNotifications:(NSDictionary*)userNotification    application:(UIApplication *)application
{
    if(application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground){
        if([userNotification[@"aps"] objectForKey:@"postId"]){
            
            PostModel *model = [PostModel new];
            model.postId = [userNotification[@"aps"] objectForKey:@"postId"];
            PostDetailsController *postDetailsVC = [(AppObj).pawan_storyboard instantiateViewControllerWithIdentifier:@"PostDetailsController"];
            postDetailsVC.selPostModel = model;
            [UTILS topMostController].hidesBottomBarWhenPushed = NO;
            [[UTILS topMostController].navigationController pushViewController:postDetailsVC animated:YES];
            
            UTILS.apnsDictionary = [NSDictionary dictionaryWithDictionary:userNotification];
        }
        else  {
            // [self openChatDetail:userNotification];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_PUSH_NOTIFICATION object:userNotification];
}

-(void)openChatDetail:(NSDictionary*)userNotification
{
    
    //   NSString * contactId = notification.object;
    
    
    // NSString *type = (NSString *)[userNotification valueForKey:@"AL_KEY"];
    NSString *alValueJson = (NSString *)[userNotification valueForKey:@"AL_VALUE"];
    
    NSData* data = [alValueJson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *theMessageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *contactId = [theMessageDict valueForKey:@"message"];
    
    //amolchat
    //self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    NSBundle * bundle = [NSBundle bundleForClass:ALMessagesViewController.class];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Applozic" bundle:bundle];
    
    ALChatViewController*   detailChatViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    detailChatViewController.navigationController.navigationBarHidden = NO;
    
    
    
    //        if([ALApplozicSettings isContactsGroupEnabled ] && _contactsGroupId)
    //        {
    //            [ALApplozicSettings setContactsGroupId:_contactsGroupId];
    //        }
    detailChatViewController.contactIds = contactId;
    // detailChatViewController.chatViewDelegate = self;
    //  detailChatViewController.channelKey = self.channelKey;
    [[UTILS topMostControllerNormal].navigationController pushViewController:detailChatViewController animated:YES];
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    NSArray *pathComponents = [url pathComponents];
    NSString *action = url.host;
    // handle URL
    
    return YES;
}

-(void)ProfileShowFromChat:(NSNotification*)notificationObj
{
    if ([notificationObj.name isEqualToString:@"chat_open_profile"]) {
        NSString *userId = notificationObj.object;
        [UTILS showUserProfileSingleController:userId];
        
    }
}

@end
