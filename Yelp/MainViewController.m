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

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, FilterUIViewControllerDelegate, UISearchBarDelegate, MKMapViewDelegate>
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BusinessCell *dummyCell;
@property (nonatomic, strong) UISearchBar *searchBar;

- (void) fetchBusinessesWithQuery: (NSString *) query params:(NSDictionary *) params;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

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

    [self.mapView setHidden:YES];

    self.title = @"Yelp";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];

    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];

    self.searchBar = [UISearchBar new];
    self.searchBar.barTintColor = [UIColor colorWithRed:255.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1];
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;

    self.searchBar.delegate = self;
    self.mapView.delegate = self;
}

- (void)onMapButton {

    BOOL switchToMapView = [self.mapView isHidden];

    if (switchToMapView) {
        self.navigationItem.rightBarButtonItem.title = @"List";
        [self.tableView setHidden:YES];
        [self.mapView setHidden:NO];

        [self updateMapWithValues];
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Map";
        [self.tableView setHidden:NO];
        [self.mapView setHidden:YES];

        [self.tableView reloadData];
    }

}

#pragma mark - SearchBar delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self fetchBusinessesWithQuery:self.searchBar.text params:nil];
    [self.searchBar resignFirstResponder];
}

- (void)onFilterButton {

    FilterUIViewController *vc = [[FilterUIViewController alloc] init];
    vc.delegate = self;

    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:255.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1];
    nvc.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    [self presentViewController:nvc animated:YES completion:nil];

}

- (void)filterViewController:(FilterUIViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {

    NSLog(@"Filters : %@", filters);
    [self fetchBusinessesWithQuery:@"Restaurants" params:filters];

}

#pragma mark - TableView delegate methods

- (void)scrollViewDidScroll :(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
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

        if ([self.tableView isHidden])
            [self updateMapWithValues];
        else
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

#pragma mark - MapView delegate methods


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.searchBar resignFirstResponder];
}

#pragma mark - private methods

- (void) updateMapWithValues {

    [self.mapView removeAnnotations:self.mapView.annotations];

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.774866,-122.394556);

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];


    for (Business *business in self.businesses) {
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];

        point.coordinate = CLLocationCoordinate2DMake(business.lat, business.lng);
        point.title = business.businessName;
        point.subtitle = business.categories;

        [self.mapView addAnnotation:point];
    }
}


@end
