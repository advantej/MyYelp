//
//  PricePreferenceCell.m
//  Yelp
//
//  Created by Tejas Lagvankar on 1/30/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "PricePreferenceCell.h"

@implementation PricePreferenceCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
