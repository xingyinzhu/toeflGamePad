//
//  Word.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "Word.h"

@implementation Word
{
    NSUInteger showLength;
    NSUInteger hideLength;
}

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

- (NSComparisonResult) compareProgress: (Word *)other
{
    if (self.progress > other.progress)
    {
        return (NSComparisonResult)NSOrderedDescending;
    }
    else if (self.progress < other.progress)
    {
        return (NSComparisonResult)NSOrderedAscending;
    }
    else
        return (NSComparisonResult)NSOrderedSame;
}

- (NSString *)configureForMark
{
    NSString * temp = [NSString stringWithFormat:@"%s%@", "[", self.englishmark];
    return [NSString stringWithFormat:@"%@%s", temp, "]"];
}

- (NSMutableString *)configureWordByShowLengthAndHideLength
{
    NSMutableString * partWord = [[NSMutableString alloc]init];
    [partWord appendString:[self.word substringToIndex:showLength]];
    
    
    for (int i = 0; i < hideLength ; i++)
    {
        [partWord appendString:@"_"];
    }
    return partWord;

}

- (NSString *)showInitPartWord;
{
    showLength = ceil(self.word.length * 0.25);
    hideLength = self.word.length - showLength;
    
    return [self configureWordByShowLengthAndHideLength];
}


- (NSString *)giveOneHint: (NSString *)currentWord
{
    //NSUInteger currentLength = currentWord.length;
    int terminateLength = ceil([self.word length] * 0.75);
    if (showLength + 1 < terminateLength)
    {
        showLength ++;
        hideLength --;
        
        return [self configureWordByShowLengthAndHideLength];
    }
    else
    {
        return currentWord;
    }
}

@end
