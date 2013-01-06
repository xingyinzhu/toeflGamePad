//
//  ViewController.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-18.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *reviewButton;
@property (nonatomic, weak) IBOutlet UIButton *testButton;
@property (nonatomic, weak) IBOutlet UIButton *howtoButton;

@property (nonatomic, weak) IBOutlet UILabel *testmark;

- (IBAction)newReview;
- (IBAction)newTest;

@end
