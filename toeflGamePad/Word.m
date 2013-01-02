//
//  Word.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "Word.h"

@implementation Word

@synthesize word = _word;
@synthesize englishmark = _englishmark;
@synthesize americamark = _americamark;
@synthesize meanings = _meanings;
@synthesize group = _group;
@synthesize hint = _hint;
@synthesize type = _type;
@synthesize progress = _progress;

- (NSComparisonResult) compareName: (Word *)other
{
    return [self.word localizedStandardCompare:other.word];
}

- (NSString *)configureForMark
{
    
    NSString * temp = [NSString stringWithFormat:@"%s%@", "[", self.englishmark];
    return [NSString stringWithFormat:@"%@%s", temp, "]"];

}

- (NSString *)showInitPartWord;
{
    NSUInteger halfLength = self.word.length / 3;
    return [self.word substringToIndex:halfLength];
}


- (NSString *)giveOneHint: (NSString *)currentWord
{
    NSUInteger currentLength = currentWord.length;

    if (currentLength + 1 < [self.word length] * 0.75)
    {
        return [self.word substringToIndex:currentLength + 1];
    }
    else
    {
        return currentWord;
    }
}

@end
