//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Greyson Gregory on 10/20/15.
//  Copyright © 2015 Grey. All rights reserved.
//

#import "MovieViewController.h"
#import "MovieDetailsViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "BFRadialWaveHUD.h"


@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *moviesTableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (nonatomic) BOOL isFiltered;
@property (strong, nonatomic) UIRefreshControl *refreshController;
@property (weak, nonatomic) IBOutlet UILabel *networkErrorLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *moviesSearchBar;
@end

@implementation MovieViewController

- (BOOL) fetchMovies {
    __block BOOL successfulFetch = NO;
    NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                    self.movies = responseDictionary[@"movies"];
                                                    [self.moviesTableView reloadData];
                                                    successfulFetch = YES;
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];

    [self.networkErrorLabel setHidden:successfulFetch];

    return successfulFetch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.networkErrorLabel setHidden:YES];
    
    self.moviesTableView.dataSource = self;
    self.moviesTableView.delegate = self;
    
    self.moviesSearchBar.delegate = self;
    
    self.refreshController = [[UIRefreshControl alloc] init];
    [self.refreshController addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.moviesTableView insertSubview:self.refreshController atIndex:0];

    BFRadialWaveHUD *hud = [[BFRadialWaveHUD alloc] initWithView:self.view
                                                      fullScreen:YES
                                                         circles:BFRadialWaveHUD_DefaultNumberOfCircles
                                                     circleColor:nil
                                                            mode:BFRadialWaveHUDMode_Default
                                                     strokeWidth:BFRadialWaveHUD_DefaultCircleStrokeWidth];
    [hud showWithMessage:@"Loading Movies"];

    [self fetchMovies];
    
    [hud showSuccessWithMessage:@"Movies Sucessfully Loaded!"];

    [hud dismissAfterDelay:2.0f];
}

- (void)refresh {
    [self fetchMovies];
    [self.refreshController endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowCount;
    if(self.isFiltered)
        rowCount = self.filteredMovies.count;
    else
        rowCount = self.movies.count;
    
    return rowCount;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoviesTableViewCell *cell = [self.moviesTableView dequeueReusableCellWithIdentifier:@"movieCell"];
    NSArray *moviesToUse = self.movies;
    if (self.isFiltered) {
        moviesToUse = self.filteredMovies;
    }
    cell.titleLabel.text = moviesToUse[indexPath.row][@"title"];
    cell.summaryLabel.text = moviesToUse[indexPath.row][@"synopsis"];
    
    NSString *thumbnailString = moviesToUse[indexPath.row][@"posters"][@"thumbnail"];
    
    NSURL *url = [NSURL URLWithString:thumbnailString];
    [cell.posterImageView setImageWithURL:url];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.moviesTableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     //NSLog(@"I'm abt to segue");
     NSArray *moviesToUse = self.movies;
     if (self.isFiltered) {
         moviesToUse = self.filteredMovies;
     }

     MoviesTableViewCell *cell = (MoviesTableViewCell *) sender;
     
     NSIndexPath *indexPath = [self.moviesTableView indexPathForCell:cell];
     
     NSDictionary *movie = moviesToUse[indexPath.row];
     
     MovieDetailsViewController *movieDetailsViewController = (MovieDetailsViewController *) segue.destinationViewController;
     
     movieDetailsViewController.movie = movie;
 }

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0) {
        self.isFiltered = FALSE;
    } else {
        self.isFiltered = TRUE;
        self.filteredMovies = [[NSMutableArray alloc] init];
        
        for (NSDictionary *movie in self.movies) {
            NSRange nameRange = [movie[@"title"] rangeOfString:text options:NSCaseInsensitiveSearch];
            //NSRange descriptionRange = [movie[@"synopsis"] rangeOfString:text options:NSCaseInsensitiveSearch];
           
            if(nameRange.location != NSNotFound) { // || descriptionRange.location != NSNotFound) {
                [self.filteredMovies addObject:movie];
            }
        }
    }
    
    [self.moviesTableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    [self.view endEditing:YES];
//    [self.moviesSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [searchBar resignFirstResponder];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    [self.moviesSearchBar resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
