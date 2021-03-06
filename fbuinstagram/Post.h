//
//  Post.h
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/9/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import <Parse/Parse.h>

@interface Post : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *createdAtString;
@property int likeCount;
@property int commentCount;
@property (nonatomic, strong) NSString *location;
@property (strong, nonatomic) NSArray *likers;

+ (void) postUserImage: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withLocation: ( NSString * _Nullable )location withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (PFFile *)getPFFileFromImage: (UIImage * _Nullable)image;

@end
