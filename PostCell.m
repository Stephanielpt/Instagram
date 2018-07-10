//
//  postCell.m
//  
//
//  Created by Stephanie Lampotang on 7/9/18.
//

#import "PostCell.h"
#import "Post.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (PostCell*)setPost:(Post *)postToCell {
    PostCell *createdCell;
//    createdCell.ppImage = postToCell.image;
//    createdCell.ppImage = postToCell.;
    return createdCell;
}
@end
