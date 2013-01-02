//
//  DetailViewController.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 13-1-1.
//  Copyright (c) 2013年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Word;

typedef enum
{
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
}DetailViewControllerAnimationType;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Word *word;

- (void)presentInParentViewController:(UIViewController *)parentViewController;

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;

@end
