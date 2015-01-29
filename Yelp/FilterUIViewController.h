//
//  FilterUIViewController.h
//  Yelp
//
//  Created by Tejas Lagvankar on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterUIViewController;

@protocol FilterUIViewControllerDelegate <NSObject>

- (void) filterViewController:(FilterUIViewController *) filterViewController didChangeFilters:(NSDictionary *)filters;

@end

@interface FilterUIViewController : UIViewController

@property (nonatomic, weak) id<FilterUIViewControllerDelegate> delegate;

@end
