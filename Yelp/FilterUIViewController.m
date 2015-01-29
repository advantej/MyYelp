//
//  FilterUIViewController.m
//  Yelp
//
//  Created by Tejas Lagvankar on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterUIViewController.h"

@interface FilterUIViewController ()

@property (nonatomic, readonly) NSDictionary *filters;

@end

@implementation FilterUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
}

- (void)onFilterButton {
    [self.delegate filterViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onCancelButton {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
