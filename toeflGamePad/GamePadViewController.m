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
    
    /*
    for (int i = 0; i < totalNumber; i++)
    {
        Word *tmp = [testWords objectAtIndex:i];
        NSLog(@"%@",tmp.word);
    }
    */
    
}
- (void)initAnimation
{
    self.word.font = [UIFont boldSystemFontOfSize:24];
    self.word.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.word.shadowColor = [UIColor colorWithWhite:1 alpha:0.75];
    self.word.shadowOffset = CGSizeMake(0, 1);
    self.word.transitionDuration = 0.75;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self GamePadInit];
    [self initAnimation];
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
            [noHintAlertView setTag:3];
            [noHintAlertView show];
        }
        else
        {
            NSLog(@"%@",hintWord);
            currentWord = hintWord;
            self.word.transitionEffect = EffectLabelTransitionCustom;
            [self.word setText:currentWord animated:YES];
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
    //category.progress = 1.0f
    //already finished
    if ([testWords count] == 0)
    {
        UIAlertView * aFinishedAlertView = [[UIAlertView alloc]
                                            initWithTitle:@"Finished"
                                            message:@"Already Finished this Category!"
                                            delegate:self
                                            cancelButtonTitle:@"Quit"
                                            otherButtonTitles:@"Restart", nil];
        [aFinishedAlertView setTag:5];
        [aFinishedAlertView show];

    }
    else
    {
        Word * tmp = [testWords objectAtIndex:currentWordIndex];
        currentWord = [tmp showInitPartWord];
        [self.word setTextColor:[UIColor whiteColor]];
        self.word.transitionEffect = EffectLabelTransitionCustom;
        [self.word setText:currentWord animated:YES];
        //self.word.text = currentWord;
        //[self.word setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
        [self.word setTextColor:[UIColor blackColor]];
        self.mark.text = @"";
        self.meangings.text = tmp.meanings;
    }
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
    //self.word.text = tmp.word;
    //[self.word setFont:[UIFont fontWithName:@"Knewave" size:24.0f]];
    //[self.word setTextColor:[UIColor yellowColor]];
    
    self.mark.text = [tmp configureForMark];
    [self.mark setTextColor:[UIColor redColor]];
    
    [self.word setTextColor:[UIColor redColor]];
    self.word.transitionEffect = EffectLabelTransitionScaleFadeOut;
    [self.word setText:tmp.word animated:YES];
    
    [self.answer setEnabled:NO];
    //[self.answer setHidden:NO];
    /*
    [self.hint setHidden:NO];
    [self.next setHidden:NO];
    [self.back setHidden:NO];
    [self.hint setEnabled:NO];
    [self.next setEnabled:NO];
    [self.back setEnabled:NO];
    */
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
            [self.answer setEnabled:YES];
            /*
            [self.hint setHidden:YES];
            [self.next setHidden:YES];
            [self.back setHidden:YES];
            [self.hint setEnabled:YES];
            [self.next setEnabled:YES];
            [self.back setEnabled:YES];
            */
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
    [self.answer setEnabled:YES];
    /*
    [self.hint setHidden:YES];
    [self.next setHidden:YES];
    [self.back setHidden:YES];
    [self.hint setEnabled:YES];
    [self.next setEnabled:YES];
    [self.back setEnabled:YES];
    */
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
    else if (alertView.tag == 3)
    {
        if (buttonIndex == 0)
        {
            self.word.transitionEffect = EffectLabelTransitionCustom;
            [self.word setText:currentWord animated:YES];
        }
    }
    else if (alertView.tag == 5)
    {
        if (buttonIndex == 0)
        {
            [self exitGamePad];
        }
        else if (buttonIndex == 1)
        {
            [DictHelper restartCategory:wordGroupInt];
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
