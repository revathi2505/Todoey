//
//  LandingViewController.h
//  GUO
//
//  Created by Parag on 6/7/18.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingViewController : UIViewController
{
    
}
@property BOOL is_came_from_sliding_menu;
@property(strong,nonatomic) IBOutlet UILabel *lblChangeLangTitle;


@property (weak, nonatomic) IBOutlet UIButton *gnewsButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
