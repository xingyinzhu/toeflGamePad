//
//  ViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-18.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "StartViewController.h"
#import "WordListViewController.h"
#import "DictHelper.h"
#import "CategoryViewController.h"
#import "AboutViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController
{
    CategoryViewController *categoryViewController;
    AboutViewController *aboutViewController;
}

@synthesize reviewButton = _reviewButton;
@synthesize testButton = _testButton;
@synthesize howtoButton = _howtoButton;
@synthesize testmark = _testmark;
@synthesize device_name = _device_name;

- (IBAction)newTest
{
    //if (categoryViewController == nil)
    //{
    categoryViewController = [[CategoryViewController alloc]initWithNibName:@"CategoryViewController" bundle:nil];
    //}
    categoryViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    categoryViewController.myToeflMode = toeflTestMode;
    categoryViewController.device_name = self.device_name;
    [self presentViewController:categoryViewController animated:YES completion:nil];
}

- (IBAction)howTo
{
    if (aboutViewController == nil)
    {
        aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    }
    aboutViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:aboutViewController animated:YES completion:nil];
}

- (IBAction)newReview
{
    //if (categoryViewController == nil)
    //{
    categoryViewController = [[CategoryViewController alloc]initWithNibName:@"CategoryViewController" bundle:nil];
    //}
    categoryViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    categoryViewController.myToeflMode = toeflReviewMode;
    categoryViewController.device_name = self.device_name;
    [self presentViewController:categoryViewController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [DictHelper loadAllWordObejctIntoDict];
    NSString *test = [DictHelper getFirstWord];
    self.testmark.text = test;
    
    [[self.reviewButton titleLabel] setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
    [[self.testButton titleLabel] setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
    [[self.howtoButton titleLabel] setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
