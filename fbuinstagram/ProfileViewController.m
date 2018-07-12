//
//  ProfileViewController.m
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/10/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Post.h"
#import "PostCollectionViewCell.h"
#import "DetailsViewController.h"
#import <ParseUI/ParseUI.h>

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *ppImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collView;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableArray *postsforCurrUser;
@property (assign, nonatomic) BOOL isMoreDataLoading;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collView.delegate = self;
    self.collView.dataSource = self;
    
    // more refresh control stuff
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getQuery:) forControlEvents:UIControlEventValueChanged];
    [self.collView insertSubview:refreshControl atIndex:0];
    
    // make call to parse to get array of posts for collection view
    [self getQuery:refreshControl];
    
    // after accessing the profile posts - we format them
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    // specify shape of profile pfimage
    self.ppImage.layer.cornerRadius = 45;
    // and username
    if(self.user) // for another user
    {
        self.screennameLabel.text = self.user.username;
    }
    else // for current user
    {
        self.screennameLabel.text = PFUser.currentUser.username;
    }
}


// query the psots to fill the collection view
- (void)getQuery:(UIRefreshControl *)refreshControl {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (error != nil)
        {
            NSLog(@"ERROR GETTING THE PARSE POSTS!");
        }
        else {
            if(posts)
            {
                self.posts = posts;
                self.postsforCurrUser = [NSMutableArray array];
                // for another user
                if(self.user)
                {
                    for(Post *post in self.posts)
                    {
                        PFUser *myUser = self.user;
                        NSString *postId = [NSString stringWithFormat:@"%@", post.author.objectId];
                        NSString *currUserId = [NSString stringWithFormat:@"%@", myUser.objectId];
                        if([postId isEqualToString:currUserId])
                        {
                            [self.postsforCurrUser addObject:post];
                        }
                    }
                }
                // for current user
                else {
                    for(Post *post in self.posts)
                    {
                        PFUser *myUser = PFUser.currentUser;
                        NSString *postId = [NSString stringWithFormat:@"%@", post.author.objectId];
                        NSString *currUserId = [NSString stringWithFormat:@"%@", myUser.objectId];
                        if([postId isEqualToString:currUserId])
                        {
                            [self.postsforCurrUser addObject:post];
                        }
                    }
                }
                NSLog(@"got 'emmmmmmmm");
                [self.collView reloadData];
                [refreshControl endRefreshing];
                //set the profile pic
                self.ppImage.file = self.postsforCurrUser[0][@"author"][@"image"];
                [self.ppImage loadInBackground];
            }
        }
    }];
}
- (IBAction)uploadTap:(id)sender {
    [self choosePic];
}



- (void)choosePic {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // editedImage = [editedImage resizeImage]
    // Do something with the images (based on your use case)
    self.ppImage.image = editedImage;
    //save the image
    PFUser *user = self.posts[0][@"author"];
    user[@"image"] = [Post getPFFileFromImage:editedImage];
    [user saveInBackground];
    //now show the image chosen
    self.ppImage.file = self.posts[0][@"author"][@"image"];
    [self.ppImage loadInBackground];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.collView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.collView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collView.isDragging) {
            self.isMoreDataLoading = true;
            
            // ... Code to load more results ...
            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
            [refreshControl addTarget:self action:@selector(getMoreQuery:) forControlEvents:UIControlEventValueChanged];
            [self.collView insertSubview:refreshControl atIndex:0];
            
            [self getMoreQuery:refreshControl];
        }
    }
}

- (void)getMoreQuery:(UIRefreshControl *)refreshControl {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    //postQuery.skip = 20;
    //    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error)
        {
        if (error != nil) {
            NSLog(@"ERROR GETTING THE EXTRA PARSE POSTS!");
        }
        else {
            if (posts) {
                self.posts = posts;
                NSLog(@"got more of 'em");
                [self.collView reloadData];
                if (refreshControl) {
                    [refreshControl endRefreshing];
                }
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // pass information from the tapped cell to the details about it
    PostCollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collView indexPathForCell:tappedCell];
    Post *post = self.postsforCurrUser[indexPath.item];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.post = post;
    detailsViewController.postCell = tappedCell;
}


- (nonnull __kindof PostCollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionViewCell" forIndexPath:indexPath];
    // assign the collection view cell it's PFImage
    Post * curPost = self.postsforCurrUser[indexPath.item];
    [cell settPost:curPost];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.postsforCurrUser.count;
}

@end
