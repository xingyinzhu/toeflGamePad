//
//  WordCell.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-31.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "WordCell.h"

@implementation WordCell

@synthesize wordLabel = _wordLabel;
@synthesize progress = _progress;

- (void)configureForWord:(NSString *)word
{
    self.wordLabel.text = word;
}

- (void)configureForProgress: (NSInteger)value
{
    float progressValue = value * 1.0 / 50;
    self.progress.progress = progressValue;
    
    UIImage *track = [[UIImage imageNamed:@"trackImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    [self.progress setTrackImage:track];
    
    UIImage *progress = [[UIImage imageNamed:@"progressImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    [self.progress setProgressImage:progress];
}

@end
