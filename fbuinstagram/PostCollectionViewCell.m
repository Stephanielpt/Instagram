//
//  PostCollectionViewCell.m
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/10/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import "PostCollectionViewCell.h"
#import "Post.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostCollectionViewCell


- (void)settPost:(Post *)post {
    if(post == nil)
    {
        NSLog(@"no pic soz");
    }
    self.post = post;
    self.postedImage.file = post.image;
    [self.postedImage loadInBackground];
}

@end
