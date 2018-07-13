//
//  PostCell.h
//  
//
//  Created by Stephanie Lampotang on 7/9/18.
//

#import <UIKit/UIKit.h>
//#import "ParseUI/ParseUI.h"
#import <ParseUI/ParseUI.h>
#import "Post.h"

@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *ppImage;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *postedImage;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) Post *post;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

- (void)settPost:(Post *)post; 
@end
