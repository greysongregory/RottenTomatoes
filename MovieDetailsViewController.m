//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Greyson Gregory on 10/20/15.
//  Copyright © 2015 Grey. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *summaryLabelContainer;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpPosterImage];
    [self setTitle:[self getTitle]];
    
    self.summaryLabel.text = self.movie[@"synopsis"];
    [self.summaryLabel sizeToFit];
    self.summaryLabelContainer.contentSize = CGSizeMake(self.summaryLabel.bounds.size.width, self.summaryLabel.bounds.size.height);
    
    // Do any additional setup after loading the view from its nib.
}

- (NSString *)getTitle {
    return [NSString stringWithFormat:@"%@ (%@)", self.movie[@"title"], self.movie[@"year"]];
}

- (void)setUpPosterImage {
    [self.posterImageView setImageWithURL:[self getLowResPosterImageURL]];
    [self.posterImageView setImageWithURL:[self getHighResPosterImageURL]];
}

- (NSURL *)getLowResPosterImageURL {
    NSString *lowResPosterThumbnailURL = self.movie[@"posters"][@"thumbnail"];
    return [NSURL URLWithString:lowResPosterThumbnailURL];
}

- (NSURL *)getHighResPosterImageURL {
    NSString *originalPosterURL = self.movie[@"posters"][@"original"];
    NSRange range = [originalPosterURL rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *highResPosterURL = [originalPosterURL stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    return [NSURL URLWithString:highResPosterURL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
