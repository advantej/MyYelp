//
//  PreferenceCell.m
//  Yelp
//
//  Created by Tejas Lagvankar on 1/30/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "PreferenceCell.h"


@interface PreferenceCell()

@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;

@end


@implementation PreferenceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureWithLabel:(NSString *)labelText selected:(BOOL)selected {
    self.preferenceLabel.text = labelText;
    self.selectedImage.image = selected ? [UIImage imageNamed:@"select"] : nil;
}


@end
