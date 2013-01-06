//
//  DetailViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 13-1-1.
//  Copyright (c) 2013年 Xingyin Zhu. All rights reserved.
//

#import "DetailViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "Word.h"
#import "GradientView.h"

@interface DetailViewController ()
{
    GradientView *gradientView;
}

- (IBAction)close:(id)sender;

@property (nonatomic, weak) IBOutlet UILabel *wordname;
@property (nonatomic, weak) IBOutlet UILabel *englishmark;
@property (nonatomic, weak) IBOutlet UILabel *hint;
@property (nonatomic, weak) IBOutlet UILabel *meanings;

@end

@implementation DetailViewController

@synthesize wordname = _wordname;
@synthesize englishmark = _englishmark;
@synthesize hint = _hint;
@synthesize meanings = _meanings;

- (IBAction)close:(id)sender
{
    [self dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
    gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:gradientView];
    
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.7f],
                              [NSNumber numberWithFloat:1.2f],
                              [NSNumber numberWithFloat:0.9f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
    
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.334f],
                                [NSNumber numberWithFloat:0.666f],
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       nil];
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];

    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f]; fadeAnimation.duration = 0.1;
    [gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType
{
    [self willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.4 animations:
     ^{
         if (animationType == DetailViewControllerAnimationTypeSlide)
         {
             CGRect rect = self.view.bounds;
             rect.origin.y += rect.size.height;
             self.view.frame = rect;
         }
         else
         {
             self.view.alpha = 0.0f;
         }
         gradientView.alpha = 0.0f;
     }
                     completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
         [gradientView removeFromSuperview];
         [self removeFromParentViewController];
     }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wordname.text = self.word.word;
    [self.wordname setFont:[UIFont fontWithName:@"Knewave" size:20.0f]];
    [self.wordname setTextColor:[UIColor whiteColor]];
    self.englishmark.text = [self.word configureForMark];
    self.meanings.text = self.word.meanings;
    if (self.word.hint == nil)
    {
        self.hint.text = @"暂无记忆法";
    }
    else
    {
        self.hint.text = self.word.hint;
    }
}


@end
