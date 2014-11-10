//
//  ShyftCell.m
//  Shyft
//
//  Created by Gauthier Petetin on 17/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "ShyftCell.h"

@implementation ShyftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

/*
- (void)performAnimation
{
    __weak ShyftCell *weakSelf = self;
    [UILabel animateWithDuration:0.1
                           delay:0
                         options:UIViewAnimationOptionCurveEaseIn
                      animations:^{
                          weakSelf.bottomLabel.alpha = 1;
                      } completion:^(BOOL finished) {
                          [weakSelf resetLabels];
                          
                          // keep performing the animation until all letters are white
                          if (weakSelf.numWhiteCharacters == [weakSelf.attributedString length]) {
                              [weakSelf.bottomLabel removeFromSuperview];
                          } else {
                              [weakSelf performAnimation];
                          }
                      }];
}

- (void)resetLabels
{
    [self.topLabel removeFromSuperview];
    self.topLabel.alpha = 0;
    
    // recalculate attributed string with the new white color values
    self.attributedString = [self randomlyFadedAttributedStringFromAttributedString:self.attributedString];
    self.topLabel.attributedText = self.attributedString;
    
    [self.bigImageView insertSubview:self.topLabel belowSubview:self.bottomLabel];
    
    //  the top label is now on the bottom, so switch
    UILabel *oldBottom = self.bottomLabel;
    UILabel *oldTopLabel = self.topLabel;
    
    self.bottomLabel = oldTopLabel;
    self.topLabel = oldBottom;
}

- (NSAttributedString *)randomlyFadedAttributedStringFromString:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    for (NSUInteger i = 0; i < [string length]; i ++) {
        UIColor *color = [self whiteColorWithClearColorProbability:10];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(id)color range:NSMakeRange(i, 1)];
        [self updateNumWhiteCharactersForColor:color];
    }
    
    return [attributedString copy];
}

- (NSAttributedString *)randomlyFadedAttributedStringFromAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    
    __weak ShyftCell *weakSelf = self;
    for (NSUInteger i = 0; i < attributedString.length; i ++) {
        [attributedString enumerateAttribute:NSForegroundColorAttributeName
                                     inRange:NSMakeRange(i, 1)
                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                                      UIColor *initialColor = value;
                                      UIColor *newColor = [weakSelf whiteColorFromInitialColor:initialColor];
                                      if (newColor) {
                                          [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:newColor range:range];
                                          [weakSelf updateNumWhiteCharactersForColor:newColor];
                                      }
                                  }];
        
    }
    
    return [mutableAttributedString copy];
}

- (void)updateNumWhiteCharactersForColor:(UIColor *)color
{
    CGFloat alpha = CGColorGetAlpha(color.CGColor);
    if (alpha == 1.0) {
        self.numWhiteCharacters++;
    }
}

- (UIColor *)whiteColorFromInitialColor:(UIColor *)initialColor
{
    UIColor *newColor;
    if ([initialColor isEqual:[UIColor clearColor]])
    {
        newColor = [self whiteColorWithClearColorProbability:4];
    } else {
        CGFloat alpha = CGColorGetAlpha(initialColor.CGColor);
        if (alpha != 1.0) {
            newColor = [self whiteColorWithMinAlpha:alpha];
        }
    }
    return newColor;
}

- (UIColor *)whiteColorWithClearColorProbability:(NSInteger)probability
{
    UIColor *color;
    NSInteger colorIndex = arc4random() % probability;
    if (colorIndex != 0) {
        color = [UIColor clearColor];
    } else {
        color = [self whiteColorWithMinAlpha:0];
    }
    return color;
}

- (UIColor *)whiteColorWithMinAlpha:(CGFloat)minAlpha
{
    NSInteger randomNumber = minAlpha * 100 + arc4random_uniform(100 - minAlpha * 100 + 1);
    CGFloat randomAlpha = randomNumber / 100.0;
    return [UIColor colorWithWhite:0.0 alpha:randomAlpha];
}*/



@end



