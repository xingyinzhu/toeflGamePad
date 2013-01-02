//
//  Word.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject

@property (nonatomic, copy) NSString * word;
@property (nonatomic, copy) NSString * englishmark;
@property (nonatomic, copy) NSString * americamark;
@property (nonatomic, copy) NSString * meanings;
@property (nonatomic, copy) NSString * group;
@property (nonatomic, copy) NSString * hint;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger progress;


- (NSComparisonResult) compareName: (Word *)other;

- (NSString *)configureForMark;

- (NSString *)showInitPartWord;

- (NSString *)giveOneHint: (NSString *)currentWord;

@end
