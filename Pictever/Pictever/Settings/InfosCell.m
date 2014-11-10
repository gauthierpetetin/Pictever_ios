//
//  InfosCell.m
//  Shyft
//
//  Created by Gauthier Petetin on 23/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "InfosCell.h"

@implementation InfosCell

NSString *username;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLabel.text = @"My Infos";
        _emailTitleLabel.text = @"Email adress";
        _phoneTitleLabel.text = @"Phone Number";
        _infosImgv.image = [UIImage imageNamed:@"bulle_info.png"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end