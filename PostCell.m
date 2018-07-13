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

//- (PostCell*)setPost:(Post *)postToCell {
//    PostCell *createdCell;
////    createdCell.ppImage = postToCell.image;
////    createdCell.ppImage = postToCell.;
//    return createdCell;
//}

- (IBAction)likeTap:(id)sender {
    // already liked so goal is to unlike
    PFUser *myUser = PFUser.currentUser;
    if(self.likeButton.selected)
    {
        self.post.likeCount--;
        self.likeButton.selected = NO;
        for(NSString *usersId in self.post.likers)
        {
            if([usersId isEqualToString:myUser.objectId])
            {
                [self.post.likers removeObject:usersId];
            }
        }
    }
    else { // not yet liked so goal is to like
        self.post.likeCount++;
        self.likeButton.selected = YES;
        [self.post.likers addObject: myUser.objectId];
    }
    Post *post = self.post;
    [post saveInBackground];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d", self.post.likeCount];
}

- (void)settPost:(Post *)post {
    if(post == nil)
    {
        NSLog(@"mo pic soz");
    }
    self.post = post;
    self.postedImage.file = post[@"image"];
    [self.postedImage loadInBackground];
    self.ppImage.file = post.author[@"image"];
    [self.ppImage loadInBackground];
    self.ppImage.layer.cornerRadius = 25;
//    if(self.post.likeCount != 0)
//    {
//        self.likeButton.selected = YES;
//    }
//    else {
//        self.likeButton.selected = NO;
//    }
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d", self.post.likeCount];
    self.locationLabel.text = self.post.location;
    self.dateLabel.text = post.createdAtString;
    BOOL iliked = NO;
    PFUser *myUser = PFUser.currentUser;
    for(NSString *string in self.post.likers)
    {
        if([myUser.objectId isEqualToString:string])
        {
            iliked = YES;
        }
    }
    if(iliked)
    {
        self.likeButton.selected = YES;
    }
}
@end
