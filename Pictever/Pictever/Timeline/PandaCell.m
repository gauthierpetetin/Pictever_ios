//
//  PandaCell.m
//  Shyft
//
//  Created by Gauthier Petetin on 24/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "PandaCell.h"

@implementation PandaCell

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