//
//  ViewController.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-18.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *category;

@property (nonatomic, weak) IBOutlet UILabel *testmark;

- (IBAction)categoryChoose;

@end
