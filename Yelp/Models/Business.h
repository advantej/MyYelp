//
// Created by Tejas Lagvankar on 1/28/15.
// Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Business : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *businessName;
@property (nonatomic, strong) NSString *ratingImageUrl;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property(nonatomic, assign) CGFloat distance;
@property(nonatomic, assign) CGFloat lat;
@property(nonatomic, assign) CGFloat lng;

+ (NSArray *)businessesWithDictionaries: (NSArray *) dictionaries;

@end