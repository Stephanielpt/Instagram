//
//  LocationCell.h
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/15/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
- (void)updateWithLocation:(NSDictionary *)location;

@end
