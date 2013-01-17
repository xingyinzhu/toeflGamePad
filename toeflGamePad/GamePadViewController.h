//
//  GamePadViewController.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-23.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectLabel.h"

@interface GamePadViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton * back;
@property (nonatomic, weak) IBOutlet UIButton * next;
@property (nonatomic, weak) IBOutlet UIButton * previous;
@property (nonatomic, weak) IBOutlet UIButton * hint;
@property (nonatomic, weak) IBOutlet UIButton * answer;
@property (nonatomic, weak) IBOutlet UIButton * accept;
@property (nonatomic, weak) IBOutlet UIButton * reject;

@property (nonatomic, weak) IBOutlet EffectLabel * word;
@property (nonatomic, weak) IBOutlet UILabel * mark;
@property (nonatomic, weak) IBOutlet UILabel * meangings;

- (IBAction)backToCategoryView;
- (IBAction)giveOneHint;
- (IBAction)showPreviousWord;
- (IBAction)showNextWord;
- (IBAction)showAnswer;
- (IBAction)acceptAnswer;
- (IBAction)rejectAnswer;

@property (nonatomic, strong) NSNumber * wordGroup;

@end
