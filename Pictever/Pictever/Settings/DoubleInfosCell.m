//
//  DoubleInfosCell.m
//  Pictever
//
//  Created by Gauthier Petetin on 08/01/2015.
//  Copyright (c) 2015 Pictever. All rights reserved.
//

#import "DoubleInfosCell.h"

@implementation DoubleInfosCell

NSString *username;
NSString *myLocaleString;

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

@end