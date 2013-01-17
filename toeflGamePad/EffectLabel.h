//
//  EffectLabel.h
//  toeflGamePad
//
//  Created by Zhu Xingyin on 13-1-17.
//  Copyright (c) 2013年 Xingyin Zhu. All rights reserved.
//



#pragma mark - Enums

typedef enum
{
	// User must provide pre-transition and transition blocks
	EffectLabelTransitionCustom = 0,
    
    EffectLabelTransitionFadeIn    = 1 << 0,
	EffectLabelTransitionFadeOut   = 1 << 1,
	EffectLabelTransitionCrossFade = EffectLabelTransitionFadeIn |
    EffectLabelTransitionFadeOut,
    
	EffectLabelTransitionZoomIn  = 1 << 2,
	EffectLabelTransitionZoomOut = 1 << 3,
    
    EffectLabelTransitionScaleFadeOut = EffectLabelTransitionFadeIn |
                                        EffectLabelTransitionFadeOut |
                                        EffectLabelTransitionZoomOut,
    EffectLabelTransitionScaleFadeIn  = EffectLabelTransitionFadeIn |
                                        EffectLabelTransitionFadeOut |
                                        EffectLabelTransitionZoomIn,
    
    // These two move the entering label from above/below to center and exiting label up/down without cross-fade
    // It's a good idea to set the clipsToBounds property of the BBCyclingLabel to true and use this in a confined space
    EffectLabelTransitionScrollUp   = 1 << 4,
    EffectLabelTransitionScrollDown = 1 << 5,
    
    EffectLabelTransitionDefault = EffectLabelTransitionCrossFade
} EffectLabelTransition;

#pragma mark - Custom types

typedef void(^EffectLabelPreTransitionBlock)(UILabel* labelToEnter);
typedef void(^EffectLabelTransitionBlock)(UILabel* labelToExit, UILabel* labelToEnter);


@interface EffectLabel : UIView

#pragma mark Public properties

@property(assign, nonatomic) EffectLabelTransition          transitionEffect;
@property(copy,   nonatomic) EffectLabelPreTransitionBlock  preTransitionBlock;
@property(copy,   nonatomic) EffectLabelTransitionBlock     transitionBlock;
@property(assign, nonatomic) NSTimeInterval                 transitionDuration;
// Same properties as UILabel, these will be propagated to the underlying labels
@property(copy,   nonatomic) NSString*            text;
@property(strong, nonatomic) UIFont*              font;
@property(strong, nonatomic) UIColor*             textColor;
@property(strong, nonatomic) UIColor*             shadowColor;
@property(assign, nonatomic) CGSize               shadowOffset;
@property(assign, nonatomic) UITextAlignment      textAlignment;
@property(assign, nonatomic) UILineBreakMode      lineBreakMode;
@property(assign, nonatomic) NSInteger            numberOfLines;
@property(assign, nonatomic) BOOL                 adjustsFontSizeToFitWidth;
@property(assign, nonatomic) CGFloat              minimumFontSize;
@property(assign, nonatomic) UIBaselineAdjustment baselineAdjustment;

#pragma mark Creation

- (id)initWithFrame:(CGRect)frame andTransitionType:(EffectLabelTransition)transitionEffect;

#pragma mark Public methods

/*! Sets the text for the next label and performs a transition between current and next label (if animated is YES) */
- (void)setText:(NSString*)text animated:(BOOL)animated;

@end

