//
//  WordCell.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-31.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * wordLabel;
@property (nonatomic, weak) IBOutlet UIProgressView * progress;

- (void)configureForWord: (NSString *)word;

- (void)configureForProgress: (NSInteger)value;

@end
