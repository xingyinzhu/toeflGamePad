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

@synthesize category = _category;
@synthesize testmark = _testmark;

- (IBAction)categoryChoose
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
    
    NSString *test = [DictHelper getFirstWord];
    self.testmark.text = test;
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
