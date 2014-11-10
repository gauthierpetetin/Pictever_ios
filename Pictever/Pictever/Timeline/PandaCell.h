//
//  PandaCell.h
//  Shyft
//
//  Created by Gauthier Petetin on 24/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PandaCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImgv;
@property (weak, nonatomic) IBOutlet UIImageView *pandaImgv;
@property (weak, nonatomic) IBOutlet UILabel *pandaSpeakLabel;

@end