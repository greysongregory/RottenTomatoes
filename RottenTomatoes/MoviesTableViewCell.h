//
//  MoviesTableViewCell.h
//  RottenTomatoes
//
//  Created by Greyson Gregory on 10/20/15.
//  Copyright © 2015 Grey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;

@end
