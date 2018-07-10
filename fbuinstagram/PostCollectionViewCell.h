//
//  PostCollectionViewCell.h
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/10/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "ParseUI/ParseUI.h"

@interface PostCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) Post *post;
@property (weak, nonatomic) IBOutlet PFImageView *postedImage;

- (void)settPost:(Post *)post;

@end
