//
//  ShyftCell.h
//  Shyft
//
//  Created by Gauthier Petetin on 17/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ShyftCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myContentView;

@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *fbButton;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
/*@property (weak, nonatomic) IBOutlet UILabel *messageLabelBis;

@property (strong, nonatomic) NSAttributedString *attributedString;
@property (assign, nonatomic) NSUInteger numWhiteCharacters;

@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

- (void)performAnimation;
- (void)resetLabels;
- (NSAttributedString *)randomlyFadedAttributedStringFromString:(NSString *)string;
- (NSAttributedString *)randomlyFadedAttributedStringFromAttributedString:(NSAttributedString *)attributedString;
- (void)updateNumWhiteCharactersForColor:(UIColor *)color;
- (UIColor *)whiteColorFromInitialColor:(UIColor *)initialColor;
- (UIColor *)whiteColorWithClearColorProbability:(NSInteger)probability;
- (UIColor *)whiteColorWithMinAlpha:(CGFloat)minAlpha;*/


@end

