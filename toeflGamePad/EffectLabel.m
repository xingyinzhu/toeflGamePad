//
//  EffectLabel.m
//  toeflGamePad
//
//  Created by Zhu Xingyin on 13-1-17.
//  Copyright (c) 2013年 Xingyin Zhu. All rights reserved.
//

#import "EffectLabel.h"

#pragma mark - Constants

NSTimeInterval const kLabelDefaultTransitionDuration = 0.3;



#pragma mark -

@interface EffectLabel ()
{
    NSUInteger _currentLabelIndex;
}


#pragma mark Private properties

@property(strong, nonatomic) NSArray* labels;
@property(strong, nonatomic) UILabel* currentLabel;

#pragma mark Private helpers

- (void)setupWithEffect:(EffectLabelTransition)effect andDuration:(NSTimeInterval)duration;
- (void)prepareTransitionBlocks;
- (NSUInteger)nextLabelIndex;
- (void)resetLabel:(UILabel*)label;

@end

@implementation EffectLabel

#pragma mark Property synthesizers

@synthesize transitionEffect   = _transitionEffect;
@synthesize preTransitionBlock = _preTransitionBlock;
@synthesize transitionBlock    = _transitionBlock;
@synthesize transitionDuration = _transitionDuration;
// Private
@synthesize labels       = _labels;
@synthesize currentLabel = _currentLabel;

#pragma mark Creation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithEffect:EffectLabelTransitionDefault
                  andDuration:kLabelDefaultTransitionDuration];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupWithEffect:EffectLabelTransitionDefault
                  andDuration:kLabelDefaultTransitionDuration];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTransitionType:(EffectLabelTransition)transitionEffect;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithEffect:transitionEffect
                  andDuration:kLabelDefaultTransitionDuration];
    }
    return self;
}

- (UIBaselineAdjustment)baselineAdjustment
{
    return _currentLabel.baselineAdjustment;
}

- (void)setBaselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    for (UILabel* label in _labels) {
        label.baselineAdjustment = baselineAdjustment;
    }
}

#pragma mark Public methods

- (void)setText:(NSString*)text animated:(BOOL)animated
{
    NSUInteger nextLabelIndex = [self nextLabelIndex];
    UILabel* nextLabel = [_labels objectAtIndex:nextLabelIndex];
    UILabel* previousLabel = _currentLabel;
    
    nextLabel.text = text;
    // Resetting the label state ensures we can change the transition type without extra code on pre-transition block.
    // Without it a transition that has no alpha changes would have to ensure alpha = 1 on pre-transition block (as
    // well as with every other possible animatable property)
    [self resetLabel:nextLabel];
    
    // Update both current label index and current label pointer
    self.currentLabel = nextLabel;
    _currentLabelIndex = nextLabelIndex;
    
    // Prepare the next label before the transition animation
    if (_preTransitionBlock != nil)
    {
        _preTransitionBlock(nextLabel);
    }
    else
    {
        // If no pre-transition block is set, prepare the next label for a cross-fade
        nextLabel.alpha = 0;
    }
    
    // Unhide the label that's about to be shown
    nextLabel.hidden = NO;
    
    void (^changeBlock)() = ^()
    {
        // Perform the user provided changes
        if (_transitionBlock != nil)
        {
            _transitionBlock(previousLabel, nextLabel);
        } else {
            // If no transition block is set, perform a simple cross-fade
            previousLabel.alpha = 0;
            nextLabel.alpha = 1;
        }
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        if (finished)
        {
            // TODO this is kind of bugged since all transitions that include affine transforms always return finished
            // as true, even when it doesn't finish...
            previousLabel.hidden = YES;
        }
    };
    
    if (animated)
    {
        // Animate the transition between both labels
        [UIView animateWithDuration:_transitionDuration animations:changeBlock completion:completionBlock];
    } else {
        changeBlock();
        completionBlock(YES);
    }
}

#pragma mark Private helpers

- (void)setupWithEffect:(EffectLabelTransition)effect andDuration:(NSTimeInterval)duration
{
    NSUInteger size = 2;
    NSMutableArray* labels = [NSMutableArray arrayWithCapacity:size];
    for (NSUInteger i = 0; i < size; i++)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        label.hidden = YES;
        label.numberOfLines = 0;
        
        [labels addObject:label];
    }
    
    _currentLabelIndex = 0;
    self.currentLabel = [labels objectAtIndex:0];
    self.labels = labels;
    
    _currentLabel.hidden = NO;
    
    self.transitionEffect = effect;
    self.transitionDuration = duration;
}

- (void)prepareTransitionBlocks
{
	//if matches custom
	if (_transitionEffect == EffectLabelTransitionCustom)
    {
        self.preTransitionBlock = nil;
        self.transitionBlock = nil;
		return;
	}
    
    EffectLabelTransition type = _transitionEffect;
	self.preTransitionBlock = ^(UILabel* labelToEnter)
    {
		if (type & EffectLabelTransitionFadeIn)
        {
			labelToEnter.alpha = 0;
		}
        
		if (type & EffectLabelTransitionZoomIn)
        {
			labelToEnter.transform = CGAffineTransformMakeScale(0.5, 0.5);
		}
        
		if (type & (EffectLabelTransitionScrollUp | EffectLabelTransitionScrollDown))
        {
			CGRect frame = labelToEnter.frame;
            
			if (type & EffectLabelTransitionScrollUp)
            {
				frame.origin.y = self.bounds.size.height;
			}
            
			if (type & EffectLabelTransitionScrollDown)
            {
				frame.origin.y = 0 - frame.size.height;
			}
			labelToEnter.frame = frame;
		}
	};
	self.transitionBlock = ^(UILabel* labelToExit, UILabel* labelToEnter)
    {
		if (type & EffectLabelTransitionFadeIn)
        {
			labelToEnter.alpha = 1;
		}
        
		if (type & EffectLabelTransitionFadeOut)
        {
			labelToExit.alpha = 0;
		}
        
		if (type & EffectLabelTransitionZoomOut)
        {
			labelToExit.transform = CGAffineTransformMakeScale(1.5, 1.5);
		}
        
		if (type & EffectLabelTransitionZoomIn)
        {
			labelToEnter.transform = CGAffineTransformIdentity;
		}
        
		if (type & (EffectLabelTransitionScrollUp | EffectLabelTransitionScrollDown))
        {
			CGRect frame = labelToExit.frame;
			CGRect enterFrame = labelToEnter.frame;
            
			if (type & EffectLabelTransitionScrollUp)
            {
				frame.origin.y = 0 - frame.size.height;
				enterFrame.origin.y = roundf((self.bounds.size.height / 2) - (enterFrame.size.height / 2));
			}
            
			if (type & EffectLabelTransitionScrollDown)
            {
				frame.origin.y = self.bounds.size.height;
				enterFrame.origin.y = roundf((self.bounds.size.height / 2) - (enterFrame.size.height / 2));
			}
            
			labelToExit.frame = frame;
			labelToEnter.frame = enterFrame;
		}
	};
}

- (NSUInteger)nextLabelIndex
{
    return (_currentLabelIndex + 1) % [_labels count];
}

- (void)resetLabel:(UILabel*)label
{
    label.alpha = 1;
    label.transform = CGAffineTransformIdentity;
    label.frame = self.bounds;
}

#pragma mark Manual property accessors

- (void)setTransitionEffect:(EffectLabelTransition)transitionEffect
{
    _transitionEffect = transitionEffect;
    [self prepareTransitionBlocks];
}

- (NSString*)text
{
    return _currentLabel.text;
}

- (void)setText:(NSString*)text
{
    [self setText:text animated:YES];
}

- (UIFont*)font
{
    return _currentLabel.font;
}

- (void)setFont:(UIFont*)font
{
    for (UILabel* label in _labels)
    {
        label.font = font;
    }
}

- (UIColor*)textColor
{
    return _currentLabel.textColor;
}

- (void)setTextColor:(UIColor*)textColor
{
    for (UILabel* label in _labels)
    {
        label.textColor = textColor;
    }
}

- (UIColor*)shadowColor
{
    return _currentLabel.shadowColor;
}

- (void)setShadowColor:(UIColor*)shadowColor
{
    for (UILabel* label in _labels)
    {
        label.shadowColor = shadowColor;
    }
}

- (CGSize)shadowOffset
{
    return _currentLabel.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    for (UILabel* label in _labels)
    {
        label.shadowOffset = shadowOffset;
    }
}

- (UITextAlignment)textAlignment
{
    return _currentLabel.textAlignment;
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
    for (UILabel* label in _labels)
    {
        label.textAlignment = textAlignment;
    }
}

- (UILineBreakMode)lineBreakMode
{
    return _currentLabel.lineBreakMode;
}

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode
{
    for (UILabel* label in _labels)
    {
        label.lineBreakMode = lineBreakMode;
    }
}

- (NSInteger)numberOfLines
{
    return _currentLabel.numberOfLines;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    for (UILabel* label in _labels)
    {
        label.numberOfLines = numberOfLines;
    }
}

- (BOOL)adjustsFontSizeToFitWidth
{
    return _currentLabel.adjustsFontSizeToFitWidth;
}

- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth
{
    for (UILabel* label in _labels)
    {
        label.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
    }
}


@end
