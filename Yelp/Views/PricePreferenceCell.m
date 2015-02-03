//
//  PricePreferenceCell.m
//  Yelp
//
//  Created by Tejas Lagvankar on 1/30/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "PricePreferenceCell.h"
#import "THSegmentedControl.h"

@interface  PricePreferenceCell ()

@property (strong, nonatomic) THSegmentedControl *thSegmentedControl;

@end

@implementation PricePreferenceCell

- (void)awakeFromNib {
    // Initialization code

    NSArray *segments = @[@"$", @"$$", @"$$$", @"$$$$"];
    self.thSegmentedControl = [[THSegmentedControl alloc] initWithSegments:segments];

    CGRect frame = CGRectMake(10, 0,  300, 40);

    [self.thSegmentedControl setFrame:frame];
    self.thSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;

    [self.thSegmentedControl addTarget:self action:@selector(thControlChangedSegment:) forControlEvents:UIControlEventValueChanged];
    self.thSegmentedControl.tintColor = [UIColor grayColor];

    [self.contentView addSubview:self.thSegmentedControl];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)thControlChangedSegment:(THSegmentedControl *)thSegmentedControl {
    NSOrderedSet *orderedSet = thSegmentedControl.selectedIndexes;


    [self.delgate pricePreferenceChanged:orderedSet];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
