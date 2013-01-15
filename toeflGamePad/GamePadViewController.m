//
//  GamePadViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-23.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "GamePadViewController.h"
#import "DictHelper.h"
#import "Word.h"
#import "NSMutableArray+Shuffling.h"

@interface GamePadViewController ()

@end

@implementation GamePadViewController
{
    NSInteger wordGroupInt;
    NSMutableArray * testWords;
    NSMutableArray * score;
    NSMutableArray * isFinished;
    DictHelper * dicthelper;
    NSUInteger currentWordIndex;
    NSUInteger finished;
    NSUInteger remaining;
    NSUInteger totalNumber;
    NSString * currentWord;
}

@synthesize back = _back;
@synthesize next = _next;
@synthesize previous = _previous;
@synthesize hint = _hint;
@synthesize answer = _answer;
@synthesize accept = _accept;
@synthesize reject = _reject;

@synthesize word = _word;
@synthesize mark = _mark;
@synthesize meangings = _meangings;


@synthesize wordGroup = _wordGroup;

- (void)GamePadInit
{
    dicthelper = [[DictHelper alloc]init];
    wordGroupInt  = [self.wordGroup integerValue];
    NSLog(@"wordGroupInt : %d",wordGroupInt);
    if (wordGroupInt == -1)
    {
        testWords = [DictHelper getRandomWords];
    }
    else
    {
        testWords = [DictHelper getWordsByGroup:wordGroupInt];
    }
    [testWords shuffle];
    
    currentWordIndex = 0;
    finished = 0;
    remaining = [testWords count];
    totalNumber = remaining;
    
    isFinished = [[NSMutableArray alloc]initWithCapacity:totalNumber];
    score = [[NSMutableArray alloc]initWithCapacity:totalNumber];
    
    for (int i = 0; i < totalNumber ; i++)
    {
        score[i] = [NSNumber numberWithInteger:5];
    }
    
    for (int i = 0; i < totalNumber; i++)
    {
        isFinished[i] = [NSNumber numberWithBool:NO];
    }
    
    
    for (int i = 0; i < totalNumber; i++)
    {
        Word *tmp = [testWords objectAtIndex:i];
        NSLog(@"%@",tmp.word);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self GamePadInit];
    [self prepareForGamePad];
}


- (IBAction)giveOneHint
{
    BOOL isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    if (isfinish == NO)
    {

        Word * tmp = [testWords objectAtIndex:currentWordIndex];
        NSString * hintWord = [tmp giveOneHint:currentWord];
        if ([hintWord isEqualToString:currentWord])
        {
            UIAlertView * noHintAlertView = [[UIAlertView alloc]
                                                initWithTitle:@"Alert!"
                                                message:@"No More Hint!"
                                                delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok", nil];
            [noHintAlertView show];
        }
        else
        {
            NSLog(@"%@",hintWord);
            currentWord = hintWord;
            self.word.text = currentWord;
            [self lowerScore4CurrentWord:2];
        }
    }
    
}

- (IBAction)showPreviousWord
{
    [self findPreviousUnfinishedWordIndex];
    [self prepareForGamePad];
}

- (IBAction)showNextWord 
{
    [self findNextUnfinishedWordIndex];
    [self prepareForGamePad];
}

- (void)prepareForGamePad
{
    Word * tmp = [testWords objectAtIndex:currentWordIndex];
    currentWord = [tmp showInitPartWord];
    self.word.text = currentWord;
    //[self.word setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
    [self.word setTextColor:[UIColor whiteColor]];
    self.mark.text = @"";
    self.meangings.text = tmp.meanings;

}

-(void)findPreviousUnfinishedWordIndex
{
    currentWordIndex = currentWordIndex - 1;
    if (currentWordIndex == -1)
    {
        currentWordIndex = totalNumber - 1;
    }
    BOOL isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    while (isfinish)
    {
        currentWordIndex = currentWordIndex - 1;
        if (currentWordIndex == -1)
        {
            currentWordIndex = totalNumber - 1;
        }
        isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    }
}

- (void)findNextUnfinishedWordIndex
{

    currentWordIndex = (currentWordIndex + 1) % totalNumber;
    BOOL isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    while (isfinish)
    {
        currentWordIndex = (currentWordIndex + 1) % totalNumber;
        isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    }
}

- (IBAction)showAnswer
{
    Word * tmp = [testWords objectAtIndex:currentWordIndex];
#pragma mark to do transition mode
    self.word.text = tmp.word;
    //[self.word setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
    [self.word setTextColor:[UIColor yellowColor]];
    self.mark.text = [tmp configureForMark];
    [self.mark setTextColor:[UIColor yellowColor]];
}

- (IBAction)acceptAnswer
{
    BOOL isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    if (isfinish == NO)
    {
        remaining = remaining - 1;
        isFinished[currentWordIndex] = [NSNumber numberWithBool:YES];
        if (remaining == 0)
        {
            UIAlertView * finfishedAlertView = [[UIAlertView alloc]
                                       initWithTitle:@"Finished"
                                       message:@"Congratulations!"
                                       delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"Ok", nil];
            [finfishedAlertView setTag:1];
            [finfishedAlertView show];
        }
        else
        {
            [self showNextWord];
        }
    }
}

- (IBAction)rejectAnswer
{
    BOOL isfinish = [[isFinished objectAtIndex:currentWordIndex]boolValue];
    if (isfinish == NO)
    {
        [self lowerScore4CurrentWord:4];
    }
    [self showNextWord];
}

- (void)lowerScore4CurrentWord: (NSInteger)ration
{
    NSLog(@"before : %@",score[currentWordIndex]);
    int tmpscore = [score[currentWordIndex] integerValue];
    if (tmpscore != 0)
    {
        tmpscore /= ration;
        score[currentWordIndex] = [NSNumber numberWithInteger: tmpscore];
    }
    NSLog(@"after : %@",score[currentWordIndex]);
}

- (IBAction)backToCategoryView
{
    UIAlertView * exitAlertView = [[UIAlertView alloc]
                                   initWithTitle:@"Quit"
                                   message:@"Do you want to quit?"
                                   delegate:self
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Ok", nil];
    [exitAlertView setTag:2];
    [exitAlertView show];
}

- (void)updateScore
{
    for (int i = 0;i < totalNumber ;i++)
    {
        BOOL isfinish = [[isFinished objectAtIndex:i]boolValue];
        if (isfinish == NO)
        {
            score[i] = [NSNumber numberWithInteger:0];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)//finish all
    {
        NSLog(@"before update");
        [DictHelper updateProgress:score withWordArray:testWords withCategoryId:wordGroupInt];
        NSLog(@"after update");
        [self exitGamePad];
    }
    else if (alertView.tag == 2)//exit in half way
    {
        if (buttonIndex == 0)
        {
            //do nothing
        }
        else
        {
            [self updateScore];
            [DictHelper updateProgress:score withWordArray:testWords withCategoryId:wordGroupInt];
            [self exitGamePad];
        }
    }
}

- (void)exitGamePad
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

@end
