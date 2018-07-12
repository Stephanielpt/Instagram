//
//  DetailsViewController.m
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/10/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import "DetailsViewController.h"
#import <ParseUI/ParseUI.h>

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *ppImage;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.post == nil)
    {
        NSLog(@"the post passed in was nil");
    }
    else {
        self.screennameLabel.text = self.post.author.username;
        self.captionLabel.text = self.post.caption;
        self.dateLabel.text = self.post.createdAtString;
        self.postedImage.file = self.postCell.post[@"image"];
        [self.postedImage loadInBackground];
        self.ppImage.file = self.postCell.post[@"author"][@"image"];
        [self.ppImage loadInBackground];
        self.ppImage.layer.cornerRadius = 25;
    }
}

- (IBAction)likeTap:(id)sender {
    // already liked so goal is to unlike
    if(self.post.likeCount)
    {
        self.post.likeCount--;
        self.likeButton.selected = NO;
    }
    else { // not yet liked so goal is to like
        self.post.likeCount++;
        self.likeButton.selected = YES;
    }
    Post *post = self.post;
    //user[@"image"] = [Post getPFFileFromImage:editedImage];
    [post saveInBackground];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d", self.post.likeCount];
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
