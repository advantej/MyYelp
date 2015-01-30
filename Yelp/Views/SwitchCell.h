//
//  SwitchCell.h
//  Yelp
//
//  Created by Tejas Lagvankar on 1/29/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void) switchCell:(SwitchCell *) switchCell didUpdateValue:(BOOL)value;

@end

@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) id<SwitchCellDelegate> delgate;
@property (nonatomic, assign) BOOL on;

- (void) setOn:(BOOL) on animated:(BOOL) animated;

@end
