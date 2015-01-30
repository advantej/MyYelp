//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FilterUIViewController.h"

//NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
//NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
//NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
//NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

NSString * const kYelpConsumerKey = @"FGguVvEetfRkq5TboRP7Fw";
NSString * const kYelpConsumerSecret = @"7zJYu2HH3pwoBzhC2jzYc4REsz0";
NSString * const kYelpToken = @"BGwL_k-sXGr1vru5ZjmzUKOGuhqEiNoB";
NSString * const kYelpTokenSecret = @"Utpn9xUj9Y8uVYwDxh2rG2xlWvk";

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, FilterUIViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BusinessCell *dummyCell;

- (void) fetchBusinessesWithQuery: (NSString *) query params:(NSDictionary *) params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self fetchBusinessesWithQuery:@"Restaurants" params:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.title = @"Yelp";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];

//    UISearchBar *searchBar = [UISearchBar new];
//    searchBar.barTintColor = [UIColor colorWithRed:255.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1];
//    [searchBar sizeToFit];
//    UIView *barWrapper = [[UIView alloc]initWithFrame:searchBar.bounds];
//    [barWrapper addSubview:searchBar];
//    self.navigationItem.titleView = barWrapper;
}

- (void)onFilterButton {

    FilterUIViewController *vc = [[FilterUIViewController alloc] init];
    vc.delegate = self;

    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];

    [self presentViewController:nvc animated:YES completion:nil];

}

- (void)filterViewController:(FilterUIViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {

    NSLog(@"Filters : %@", filters);
    [self fetchBusinessesWithQuery:@"Restaurants" params:filters];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    BusinessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];

    return cell;
}


- (BusinessCell *)dummyCell {

    if (!_dummyCell) {
        _dummyCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    }
    return _dummyCell;

}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {

    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);

        NSArray *businessesDictionaries = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessesDictionaries];

        [self.tableView reloadData];


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:self.dummyCell forRowAtIndexPath:indexPath];
    [self.dummyCell layoutIfNeeded];

    CGSize size = [self.dummyCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[BusinessCell class]])
    {
        BusinessCell *textCell = (BusinessCell *)cell;
        textCell.business = self.businesses[indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
