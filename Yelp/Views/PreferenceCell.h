//
//  PreferenceCell.h
//  Yelp
//
//  Created by Tejas Lagvankar on 1/30/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferenceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *preferenceLabel;
- (void) configureWithLabel:(NSString *)labelText selected:(BOOL) selected;

@end
