//
//  FilterUIViewController.m
//  Yelp
//
//  Created by Tejas Lagvankar on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterUIViewController.h"
#import "SwitchCell.h"
#import "PreferenceCell.h"
#import "PricePreferenceCell.h"

@interface FilterUIViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, PricePreferenceCellDelegate>

@property(nonatomic, readonly) NSDictionary *filters;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *sectionsExpandedState;

@property(nonatomic, strong) NSArray *categories;
@property(nonatomic, strong) NSMutableSet *selectedCategories;

@property(nonatomic, strong) NSArray *distances;
@property(nonatomic, assign) NSUInteger selectedDistanceIndex;

@property(nonatomic, strong) NSArray *sortByPrefs;
@property(nonatomic, assign) NSUInteger selectedSortByPref;

@property(nonatomic, strong) NSArray *mostPopularPreferences;
@property(nonatomic, strong) NSMutableSet *selectedMostPopularPreferences;

@property(nonatomic, strong) NSMutableOrderedSet *selectedPricePreferences;

@end

@implementation FilterUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.sectionsExpandedState = [[NSMutableArray alloc] initWithArray:@[@NO, @NO, @NO, @NO, @YES ]];

        self.selectedCategories = [NSMutableSet set];
        [self initCategories];

        self.selectedPricePreferences = [[NSMutableOrderedSet alloc] init];

        self.selectedMostPopularPreferences = [NSMutableSet set];
        self.mostPopularPreferences = @[@"Open Now", @"Hot & New", @"Offering a Deal", @"Delivery"];

        self.distances = @[@"Best Match", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"];
        self.selectedDistanceIndex = 0;

        self.sortByPrefs = @[@"Best Match", @"Distance", @"Rating", @"Most Reviewed"];
        self.selectedSortByPref = 0;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];

    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"Settings";

    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PreferenceCell" bundle:nil] forCellReuseIdentifier:@"PreferenceCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PricePreferenceCell" bundle:nil] forCellReuseIdentifier:@"PricePreferenceCell"];
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    BOOL expanded = [self.sectionsExpandedState[(NSUInteger) section] boolValue];

    switch (section) {
        case 0:
                return 1;
        case 1:
            return self.mostPopularPreferences.count;
        case 2:
            if (expanded)
                return self.distances.count;
            else
                return 1;
        case 3:
            if (expanded)
                return self.sortByPrefs.count;
            else
                return 1;
        case 4:
            if (expanded)
                return self.categories.count;
            else
                return 5;
        default:break;
    }
    return 0;
}

- (UIView *)tableView :(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headerView.backgroundColor = [UIColor whiteColor];

    UILabel *uiLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 320, 40)];
    uiLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    uiLabel.textColor = [UIColor grayColor];

    switch (section) {
        case 0:
            uiLabel.text = @"Price";
            break;
        case 1:
            uiLabel.text = @"Most Popular";
            break;
        case 2:
            uiLabel.text = @"Distance";
            break;
        case 3:
            uiLabel.text = @"Sort By";
            break;
        case 4:
            uiLabel.text = @"Categories";
            break;
    }

    [headerView addSubview:uiLabel];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SwitchCell *switchCell = nil;
    PreferenceCell *preferenceCell = nil;
    PricePreferenceCell *pricePreferenceCell = nil;
    BOOL expanded = [self.sectionsExpandedState[(NSUInteger) indexPath.section] boolValue];

    switch (indexPath.section) {
        case 0:
            pricePreferenceCell = [tableView dequeueReusableCellWithIdentifier:@"PricePreferenceCell"];
            pricePreferenceCell.delgate = self;
            return pricePreferenceCell;
        case 1:
            switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

            switchCell.titleLabel.text = self.mostPopularPreferences[indexPath.row];
            switchCell.on = [self.selectedMostPopularPreferences containsObject:self.categories[indexPath.row]];
            switchCell.delgate = self;

            return switchCell;
        case 2:
            preferenceCell = [tableView dequeueReusableCellWithIdentifier:@"PreferenceCell"];
            if (expanded) {
                [preferenceCell configureWithLabel:self.distances[indexPath.row] selected:indexPath.row == self.selectedDistanceIndex];

            } else {
                [preferenceCell configureWithLabel:self.distances[self.selectedDistanceIndex] selected:NO];
            }
            return preferenceCell;

        case 3:
            preferenceCell = [tableView dequeueReusableCellWithIdentifier:@"PreferenceCell"];
            if (expanded) {
                [preferenceCell configureWithLabel:self.sortByPrefs[indexPath.row] selected:indexPath.row == self.selectedSortByPref];

            } else {
                [preferenceCell configureWithLabel:self.sortByPrefs[self.selectedSortByPref] selected:NO];
            }
            return preferenceCell;
        case 4:
            switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

            switchCell.titleLabel.text = self.categories[indexPath.row][@"name"];
            switchCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            switchCell.delgate = self;

            return switchCell;
    }

    UITableViewCell *placeHolderView = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    placeHolderView.backgroundColor = [UIColor greenColor];
    return placeHolderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 4)
        return;

    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:(NSUInteger) indexPath.section];
    BOOL expanded = [self.sectionsExpandedState[(NSUInteger) indexPath.section] boolValue];
    self.sectionsExpandedState[(NSUInteger) indexPath.section] = @(!expanded);

    switch (indexPath.section) {
        case 2:
            if (expanded) {
                self.selectedDistanceIndex = indexPath.row;
            }
            break;
        case 3:
            if (expanded) {
                self.selectedSortByPref = indexPath.row;
            }
            break;
    }

    [tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - Switch Cell Delegate

- (void)switchCell:(SwitchCell *)switchCell didUpdateValue:(BOOL)value {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:switchCell];
    if (indexPath.section == 4) {
        if (value) {
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }
    }

    if (indexPath.section == 1) {
        if (value) {
            [self.selectedMostPopularPreferences addObject:self.mostPopularPreferences[indexPath.row]];
        } else {
            [self.selectedMostPopularPreferences removeObject:self.mostPopularPreferences[indexPath.row]];
        }

    }

}

#pragma mark - Price Preference Delegate

- (void)pricePreferenceChanged:(NSOrderedSet *)orderedSet {

    self.selectedPricePreferences = [orderedSet mutableCopy];

    if (orderedSet.count > 0) {
        for (int i = 0; i < orderedSet.count; i++) {
            NSInteger index = [[orderedSet objectAtIndex:i] integerValue];
            NSLog(@"Selected index : %d ", index);
        }
    }
    if (orderedSet.count == 0) {
        NSLog(@"No Selected indexes ");
    }
}

#pragma mark - Private methods

- (void)onApplyButton {
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

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];

    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }

        NSString *categoryFilter = [names componentsJoinedByString:@","];
        filters[@"category_filter"] = categoryFilter;
    }

    if (self.selectedDistanceIndex != 0) {
        float milesMeter = 1609.34;
        float distance = 0;
        switch (self.selectedDistanceIndex) {
            case 1:
                distance = 0.3;
                break;
            case 2:
                distance = 1;
                break;
            case 3:
                distance = 5;
                break;
            case 4:
                distance = 20;
                break;
        }

        distance = distance * milesMeter;
        filters[@"radius_filter"] = @(distance);
    }

    if (self.selectedSortByPref != 0) {
        filters[@"sort"] = @(self.selectedSortByPref);
    }

    if (self.selectedPricePreferences.count > 0) {
        for (int i = 0; i < self.selectedPricePreferences.count; i++) {
            NSInteger index = [[self.selectedPricePreferences objectAtIndex:i] integerValue];
            NSLog(@"Selected index : %d ", index);
            //TODO set the price filter here (can't find it on yelp api)
        }
    }

    return filters;
}

- (void)initCategories {
    self.categories = @[
            @{@"name" : @"Afghan", @"code" : @"afghani"},
            @{@"name" : @"African", @"code" : @"african"},
            @{@"name" : @"Senegalese", @"code" : @"senegalese"},
            @{@"name" : @"South African", @"code" : @"southafrican"},
            @{@"name" : @"American New", @"code" : @"newamerican"},
            @{@"name" : @"American Traditional", @"code" : @"tradamerican"},
            @{@"name" : @"Arabian", @"code" : @"arabian"},
            @{@"name" : @"Arab Pizza", @"code" : @"arabpizza"},
            @{@"name" : @"Argentine", @"code" : @"argentine"},
            @{@"name" : @"Armenian", @"code" : @"armenian"},
            @{@"name" : @"Asian Fusion", @"code" : @"asianfusion"},
            @{@"name" : @"Asturian", @"code" : @"asturian"},
            @{@"name" : @"Australian", @"code" : @"australian"},
            @{@"name" : @"Austrian", @"code" : @"austrian"},
            @{@"name" : @"Baguettes", @"code" : @"baguettes"},
            @{@"name" : @"Bangladeshi", @"code" : @"bangladeshi"},
            @{@"name" : @"Barbeque", @"code" : @"bbq"},
            @{@"name" : @"Basque", @"code" : @"basque"},
            @{@"name" : @"Bavarian", @"code" : @"bavarian"},
            @{@"name" : @"Beer Garden", @"code" : @"beergarden"},
            @{@"name" : @"Beer Hall", @"code" : @"beerhall"},
            @{@"name" : @"Beisl", @"code" : @"beisl"},
            @{@"name" : @"Belgian", @"code" : @"belgian"},
            @{@"name" : @"Flemish", @"code" : @"flemish"},
            @{@"name" : @"Bistros", @"code" : @"bistros"},
            @{@"name" : @"Black Sea", @"code" : @"blacksea"},
            @{@"name" : @"Brasseries", @"code" : @"brasseries"},
            @{@"name" : @"Brazilian", @"code" : @"brazilian"},
            @{@"name" : @"Brazilian Empanadas", @"code" : @"brazilianempanadas"},
            @{@"name" : @"Central Brazilian", @"code" : @"centralbrazilian"},
            @{@"name" : @"Northeastern Brazilian", @"code" : @"northeasternbrazilian"},
            @{@"name" : @"Northern Brazilian", @"code" : @"northernbrazilian"},
            @{@"name" : @"Rodizios", @"code" : @"rodizios"},
            @{@"name" : @"Breakfast & Brunch", @"code" : @"breakfast_brunch"},
            @{@"name" : @"British", @"code" : @"british"},
            @{@"name" : @"Buffets", @"code" : @"buffets"},
            @{@"name" : @"Bulgarian", @"code" : @"bulgarian"},
            @{@"name" : @"Burgers", @"code" : @"burgers"},
            @{@"name" : @"Burmese", @"code" : @"burmese"},
            @{@"name" : @"Cafes", @"code" : @"cafes"},
            @{@"name" : @"Cafeteria", @"code" : @"cafeteria"},
            @{@"name" : @"Cajun/Creole", @"code" : @"cajun"},
            @{@"name" : @"Cambodian", @"code" : @"cambodian"},
            @{@"name" : @"Canadian New", @"code" : @"newcanadian"},
            @{@"name" : @"Canteen", @"code" : @"canteen"},
            @{@"name" : @"Caribbean", @"code" : @"caribbean"},
            @{@"name" : @"Dominican", @"code" : @"dominican"},
            @{@"name" : @"Haitian", @"code" : @"haitian"},
            @{@"name" : @"Puerto Rican", @"code" : @"puertorican"},
            @{@"name" : @"Trinidadian", @"code" : @"trinidadian"},
            @{@"name" : @"Catalan", @"code" : @"catalan"},
            @{@"name" : @"Chech", @"code" : @"chech"},
            @{@"name" : @"Cheesesteaks", @"code" : @"cheesesteaks"},
            @{@"name" : @"Chicken Shop", @"code" : @"chickenshop"},
            @{@"name" : @"Chicken Wings", @"code" : @"chicken_wings"},
            @{@"name" : @"Chilean", @"code" : @"chilean"},
            @{@"name" : @"Chinese", @"code" : @"chinese"},
            @{@"name" : @"Cantonese", @"code" : @"cantonese"},
            @{@"name" : @"Congee", @"code" : @"congee"},
            @{@"name" : @"Dim Sum", @"code" : @"dimsum"},
            @{@"name" : @"Fuzhou", @"code" : @"fuzhou"},
            @{@"name" : @"Hakka", @"code" : @"hakka"},
            @{@"name" : @"Henghwa", @"code" : @"henghwa"},
            @{@"name" : @"Hokkien", @"code" : @"hokkien"},
            @{@"name" : @"Hunan", @"code" : @"hunan"},
            @{@"name" : @"Pekinese", @"code" : @"pekinese"},
            @{@"name" : @"Shanghainese", @"code" : @"shanghainese"},
            @{@"name" : @"Szechuan", @"code" : @"szechuan"},
            @{@"name" : @"Teochew", @"code" : @"teochew"},
            @{@"name" : @"Comfort Food", @"code" : @"comfortfood"},
            @{@"name" : @"Corsican", @"code" : @"corsican"},
            @{@"name" : @"Creperies", @"code" : @"creperies"},
            @{@"name" : @"Cuban", @"code" : @"cuban"},
            @{@"name" : @"Curry Sausage", @"code" : @"currysausage"},
            @{@"name" : @"Cypriot", @"code" : @"cypriot"},
            @{@"name" : @"Czech", @"code" : @"czech"},
            @{@"name" : @"Czech/Slovakian", @"code" : @"czechslovakian"},
            @{@"name" : @"Danish", @"code" : @"danish"},
            @{@"name" : @"Delis", @"code" : @"delis"},
            @{@"name" : @"Diners", @"code" : @"diners"},
            @{@"name" : @"Dumplings", @"code" : @"dumplings"},
            @{@"name" : @"Eastern European", @"code" : @"eastern_european"},
            @{@"name" : @"Ethiopian", @"code" : @"ethiopian"},
            @{@"name" : @"Fast Food", @"code" : @"hotdogs"},
            @{@"name" : @"Filipino", @"code" : @"filipino"},
            @{@"name" : @"Fischbroetchen", @"code" : @"fischbroetchen"},
            @{@"name" : @"Fish & Chips", @"code" : @"fishnchips"},
            @{@"name" : @"Fondue", @"code" : @"fondue"},
            @{@"name" : @"Food Court", @"code" : @"food_court"},
            @{@"name" : @"Food Stands", @"code" : @"foodstands"},
            @{@"name" : @"French", @"code" : @"french"},
            @{@"name" : @"Alsatian", @"code" : @"alsatian"},
            @{@"name" : @"Auvergnat", @"code" : @"auvergnat"},
            @{@"name" : @"Berrichon", @"code" : @"berrichon"},
            @{@"name" : @"Bourguignon", @"code" : @"bourguignon"},
            @{@"name" : @"Nicoise", @"code" : @"nicois"},
            @{@"name" : @"Provencal", @"code" : @"provencal"},
            @{@"name" : @"French Southwest", @"code" : @"sud_ouest"},
            @{@"name" : @"Galician", @"code" : @"galician"},
            @{@"name" : @"Gastropubs", @"code" : @"gastropubs"},
            @{@"name" : @"Georgian", @"code" : @"georgian"},
            @{@"name" : @"German", @"code" : @"german"},
            @{@"name" : @"Baden", @"code" : @"baden"},
            @{@"name" : @"Eastern German", @"code" : @"easterngerman"},
            @{@"name" : @"Hessian", @"code" : @"hessian"},
            @{@"name" : @"Northern German", @"code" : @"northerngerman"},
            @{@"name" : @"Palatine", @"code" : @"palatine"},
            @{@"name" : @"Rhinelandian", @"code" : @"rhinelandian"},
            @{@"name" : @"Giblets", @"code" : @"giblets"},
            @{@"name" : @"Gluten-Free", @"code" : @"gluten_free"},
            @{@"name" : @"Greek", @"code" : @"greek"},
            @{@"name" : @"Halal", @"code" : @"halal"},
            @{@"name" : @"Hawaiian", @"code" : @"hawaiian"},
            @{@"name" : @"Heuriger", @"code" : @"heuriger"},
            @{@"name" : @"Himalayan/Nepalese", @"code" : @"himalayan"},
            @{@"name" : @"Hong Kong Style Cafe", @"code" : @"hkcafe"},
            @{@"name" : @"Hot Dogs", @"code" : @"hotdog"},
            @{@"name" : @"Hot Pot", @"code" : @"hotpot"},
            @{@"name" : @"Hungarian", @"code" : @"hungarian"},
            @{@"name" : @"Iberian", @"code" : @"iberian"},
            @{@"name" : @"Indian", @"code" : @"indpak"},
            @{@"name" : @"Indonesian", @"code" : @"indonesian"},
            @{@"name" : @"International", @"code" : @"international"},
            @{@"name" : @"Irish", @"code" : @"irish"},
            @{@"name" : @"Island Pub", @"code" : @"island_pub"},
            @{@"name" : @"Israeli", @"code" : @"israeli"},
            @{@"name" : @"Italian", @"code" : @"italian"},
            @{@"name" : @"Abruzzese", @"code" : @"abruzzese"},
            @{@"name" : @"Altoatesine", @"code" : @"altoatesine"},
            @{@"name" : @"Apulian", @"code" : @"apulian"},
            @{@"name" : @"Calabrian", @"code" : @"calabrian"},
            @{@"name" : @"Cucina campana", @"code" : @"cucinacampana"},
            @{@"name" : @"Emilian", @"code" : @"emilian"},
            @{@"name" : @"Friulan", @"code" : @"friulan"},
            @{@"name" : @"Ligurian", @"code" : @"ligurian"},
            @{@"name" : @"Lumbard", @"code" : @"lumbard"},
            @{@"name" : @"Napoletana", @"code" : @"napoletana"},
            @{@"name" : @"Piemonte", @"code" : @"piemonte"},
            @{@"name" : @"Roman", @"code" : @"roman"},
            @{@"name" : @"Sardinian", @"code" : @"sardinian"},
            @{@"name" : @"Sicilian", @"code" : @"sicilian"},
            @{@"name" : @"Tuscan", @"code" : @"tuscan"},
            @{@"name" : @"Venetian", @"code" : @"venetian"},
            @{@"name" : @"Japanese", @"code" : @"japanese"},
            @{@"name" : @"Blowfish", @"code" : @"blowfish"},
            @{@"name" : @"Conveyor Belt Sushi", @"code" : @"conveyorsushi"},
            @{@"name" : @"Donburi", @"code" : @"donburi"},
            @{@"name" : @"Gyudon", @"code" : @"gyudon"},
            @{@"name" : @"Oyakodon", @"code" : @"oyakodon"},
            @{@"name" : @"Hand Rolls", @"code" : @"handrolls"},
            @{@"name" : @"Horumon", @"code" : @"horumon"},
            @{@"name" : @"Izakaya", @"code" : @"izakaya"},
            @{@"name" : @"Japanese Curry", @"code" : @"japacurry"},
            @{@"name" : @"Kaiseki", @"code" : @"kaiseki"},
            @{@"name" : @"Kushikatsu", @"code" : @"kushikatsu"},
            @{@"name" : @"Oden", @"code" : @"oden"},
            @{@"name" : @"Okinawan", @"code" : @"okinawan"},
            @{@"name" : @"Okonomiyaki", @"code" : @"okonomiyaki"},
            @{@"name" : @"Onigiri", @"code" : @"onigiri"},
            @{@"name" : @"Ramen", @"code" : @"ramen"},
            @{@"name" : @"Robatayaki", @"code" : @"robatayaki"},
            @{@"name" : @"Soba", @"code" : @"soba"},
            @{@"name" : @"Sukiyaki", @"code" : @"sukiyaki"},
            @{@"name" : @"Takoyaki", @"code" : @"takoyaki"},
            @{@"name" : @"Tempura", @"code" : @"tempura"},
            @{@"name" : @"Teppanyaki", @"code" : @"teppanyaki"},
            @{@"name" : @"Tonkatsu", @"code" : @"tonkatsu"},
            @{@"name" : @"Udon", @"code" : @"udon"},
            @{@"name" : @"Unagi", @"code" : @"unagi"},
            @{@"name" : @"Western Style Japanese Food", @"code" : @"westernjapanese"},
            @{@"name" : @"Yakiniku", @"code" : @"yakiniku"},
            @{@"name" : @"Yakitori", @"code" : @"yakitori"},
            @{@"name" : @"Jewish", @"code" : @"jewish"},
            @{@"name" : @"Kebab", @"code" : @"kebab"},
            @{@"name" : @"Korean", @"code" : @"korean"},
            @{@"name" : @"Kosher", @"code" : @"kosher"},
            @{@"name" : @"Kurdish", @"code" : @"kurdish"},
            @{@"name" : @"Laos", @"code" : @"laos"},
            @{@"name" : @"Laotian", @"code" : @"laotian"},
            @{@"name" : @"Latin American", @"code" : @"latin"},
            @{@"name" : @"Colombian", @"code" : @"colombian"},
            @{@"name" : @"Salvadoran", @"code" : @"salvadoran"},
            @{@"name" : @"Venezuelan", @"code" : @"venezuelan"},
            @{@"name" : @"Live/Raw Food", @"code" : @"raw_food"},
            @{@"name" : @"Lyonnais", @"code" : @"lyonnais"},
            @{@"name" : @"Malaysian", @"code" : @"malaysian"},
            @{@"name" : @"Mamak", @"code" : @"mamak"},
            @{@"name" : @"Nyonya", @"code" : @"nyonya"},
            @{@"name" : @"Meatballs", @"code" : @"meatballs"},
            @{@"name" : @"Mediterranean", @"code" : @"mediterranean"},
            @{@"name" : @"Falafel", @"code" : @"falafel"},
            @{@"name" : @"Mexican", @"code" : @"mexican"},
            @{@"name" : @"Eastern Mexican", @"code" : @"easternmexican"},
            @{@"name" : @"Jaliscan", @"code" : @"jaliscan"},
            @{@"name" : @"Northern Mexican", @"code" : @"northernmexican"},
            @{@"name" : @"Oaxacan", @"code" : @"oaxacan"},
            @{@"name" : @"Pueblan", @"code" : @"pueblan"},
            @{@"name" : @"Tacos", @"code" : @"tacos"},
            @{@"name" : @"Tamales", @"code" : @"tamales"},
            @{@"name" : @"Yucatan", @"code" : @"yucatan"},
            @{@"name" : @"Middle Eastern", @"code" : @"mideastern"},
            @{@"name" : @"Egyptian", @"code" : @"egyptian"},
            @{@"name" : @"Lebanese", @"code" : @"lebanese"},
            @{@"name" : @"Milk Bars", @"code" : @"milkbars"},
            @{@"name" : @"Modern Australian", @"code" : @"modern_australian"},
            @{@"name" : @"Modern European", @"code" : @"modern_european"},
            @{@"name" : @"Mongolian", @"code" : @"mongolian"},
            @{@"name" : @"Moroccan", @"code" : @"moroccan"},
            @{@"name" : @"New Zealand", @"code" : @"newzealand"},
            @{@"name" : @"Night Food", @"code" : @"nightfood"},
            @{@"name" : @"Norcinerie", @"code" : @"norcinerie"},
            @{@"name" : @"Open Sandwiches", @"code" : @"opensandwiches"},
            @{@"name" : @"Oriental", @"code" : @"oriental"},
            @{@"name" : @"Pakistani", @"code" : @"pakistani"},
            @{@"name" : @"Parent Cafes", @"code" : @"eltern_cafes"},
            @{@"name" : @"Parma", @"code" : @"parma"},
            @{@"name" : @"Persian/Iranian", @"code" : @"persian"},
            @{@"name" : @"Peruvian", @"code" : @"peruvian"},
            @{@"name" : @"Pita", @"code" : @"pita"},
            @{@"name" : @"Pizza", @"code" : @"pizza"},
            @{@"name" : @"Polish", @"code" : @"polish"},
            @{@"name" : @"Pierogis", @"code" : @"pierogis"},
            @{@"name" : @"Portuguese", @"code" : @"portuguese"},
            @{@"name" : @"Alentejo", @"code" : @"alentejo"},
            @{@"name" : @"Algarve", @"code" : @"algarve"},
            @{@"name" : @"Azores", @"code" : @"azores"},
            @{@"name" : @"Beira", @"code" : @"beira"},
            @{@"name" : @"Fado Houses", @"code" : @"fado_houses"},
            @{@"name" : @"Madeira", @"code" : @"madeira"},
            @{@"name" : @"Minho", @"code" : @"minho"},
            @{@"name" : @"Ribatejo", @"code" : @"ribatejo"},
            @{@"name" : @"Tras-os-Montes", @"code" : @"tras_os_montes"},
            @{@"name" : @"Potatoes", @"code" : @"potatoes"},
            @{@"name" : @"Poutineries", @"code" : @"poutineries"},
            @{@"name" : @"Pub Food", @"code" : @"pubfood"},
            @{@"name" : @"Rice", @"code" : @"riceshop"},
            @{@"name" : @"Romanian", @"code" : @"romanian"},
            @{@"name" : @"Rotisserie Chicken", @"code" : @"rotisserie_chicken"},
            @{@"name" : @"Rumanian", @"code" : @"rumanian"},
            @{@"name" : @"Russian", @"code" : @"russian"},
            @{@"name" : @"Salad", @"code" : @"salad"},
            @{@"name" : @"Sandwiches", @"code" : @"sandwiches"},
            @{@"name" : @"Scandinavian", @"code" : @"scandinavian"},
            @{@"name" : @"Scottish", @"code" : @"scottish"},
            @{@"name" : @"Seafood", @"code" : @"seafood"},
            @{@"name" : @"Serbo Croatian", @"code" : @"serbocroatian"},
            @{@"name" : @"Signature Cuisine", @"code" : @"signature_cuisine"},
            @{@"name" : @"Singaporean", @"code" : @"singaporean"},
            @{@"name" : @"Slovakian", @"code" : @"slovakian"},
            @{@"name" : @"Soul Food", @"code" : @"soulfood"},
            @{@"name" : @"Soup", @"code" : @"soup"},
            @{@"name" : @"Southern", @"code" : @"southern"},
            @{@"name" : @"Spanish", @"code" : @"spanish"},
            @{@"name" : @"Arroceria / Paella", @"code" : @"arroceria_paella"},
            @{@"name" : @"Steakhouses", @"code" : @"steak"},
            @{@"name" : @"Sushi Bars", @"code" : @"sushi"},
            @{@"name" : @"Swabian", @"code" : @"swabian"},
            @{@"name" : @"Swedish", @"code" : @"swedish"},
            @{@"name" : @"Swiss Food", @"code" : @"swissfood"},
            @{@"name" : @"Tabernas", @"code" : @"tabernas"},
            @{@"name" : @"Taiwanese", @"code" : @"taiwanese"},
            @{@"name" : @"Tapas Bars", @"code" : @"tapas"},
            @{@"name" : @"Tapas/Small Plates", @"code" : @"tapasmallplates"},
            @{@"name" : @"Tex-Mex", @"code" : @"tex-mex"},
            @{@"name" : @"Thai", @"code" : @"thai"},
            @{@"name" : @"Traditional Norwegian", @"code" : @"norwegian"},
            @{@"name" : @"Traditional Swedish", @"code" : @"traditional_swedish"},
            @{@"name" : @"Trattorie", @"code" : @"trattorie"},
            @{@"name" : @"Turkish", @"code" : @"turkish"},
            @{@"name" : @"Chee Kufta", @"code" : @"cheekufta"},
            @{@"name" : @"Gozleme", @"code" : @"gozleme"},
            @{@"name" : @"Turkish Ravioli", @"code" : @"turkishravioli"},
            @{@"name" : @"Ukrainian", @"code" : @"ukrainian"},
            @{@"name" : @"Uzbek", @"code" : @"uzbek"},
            @{@"name" : @"Vegan", @"code" : @"vegan"},
            @{@"name" : @"Vegetarian", @"code" : @"vegetarian"},
            @{@"name" : @"Venison", @"code" : @"venison"},
            @{@"name" : @"Vietnamese", @"code" : @"vietnamese"},
            @{@"name" : @"Wok", @"code" : @"wok"},
            @{@"name" : @"Wraps", @"code" : @"wraps"},
            @{@"name" : @"Yugoslav", @"code" : @"yugoslav"},
    ];
}


@end
