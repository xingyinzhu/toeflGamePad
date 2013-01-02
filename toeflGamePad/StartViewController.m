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

@interface StartViewController ()

@end

@implementation StartViewController
{
    WordListViewController *wordListViewController;
}

@synthesize beginButton = _beginButton;
@synthesize howtoButton = _howtoButton;
@synthesize testmark = _testmark;

- (IBAction)begin
{
    if (wordListViewController == nil)
    {
        wordListViewController = [[WordListViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
        
        wordListViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:wordListViewController animated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [DictHelper loadAllWordObejctIntoDict];
    NSString *test = [DictHelper getFirstWord];
    self.testmark.text = test;
    
    [[self.beginButton titleLabel] setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
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
