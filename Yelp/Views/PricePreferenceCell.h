//
//  PricePreferenceCell.h
//  Yelp
//
//  Created by Tejas Lagvankar on 1/30/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PricePreferenceCellDelegate <NSObject>

- (void) pricePreferenceChanged:(NSOrderedSet *) orderedSet;

@end

@interface PricePreferenceCell : UITableViewCell

@property (nonatomic, weak) id<PricePreferenceCellDelegate> delgate;

@end
