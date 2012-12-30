//
//  WordListViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-23.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "WordListViewController.h"
#import "CategoryViewController.h"

@interface WordListViewController ()

@end

@implementation WordListViewController
{
    CategoryViewController *categoryViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWordListViewWithDuration:(NSTimeInterval)duration
{
    if (categoryViewController == nil)
    {
        categoryViewController = [[CategoryViewController alloc]
                                  initWithNibName:@"CategoryViewController" bundle:nil];
        
        categoryViewController.view.frame = self.view.bounds;
        categoryViewController.view.alpha = 0.0f;
        
        [self.view addSubview:categoryViewController.view];
        [self addChildViewController:categoryViewController];
        
        [UIView animateWithDuration:duration animations:
         ^{
             categoryViewController.view.alpha = 1.0f;
         } completion:^(BOOL finished)
         {
             [categoryViewController didMoveToParentViewController:self];
         }];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    }
}

- (void)hideWordListViewWithDuration:(NSTimeInterval)duration
{
    if (categoryViewController != nil)
    {
        [categoryViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:
         ^{
             categoryViewController.view.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [categoryViewController.view removeFromSuperview];
             [categoryViewController removeFromParentViewController];
             categoryViewController = nil;
         }];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [self hideWordListViewWithDuration:duration];
    }
    else
    {
        [self showWordListViewWithDuration:duration];
    }
}


@end
