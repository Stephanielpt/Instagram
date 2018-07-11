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
@property (strong, nonatomic) Post *post;

- (void)settPost:(Post *)post; 
@end
