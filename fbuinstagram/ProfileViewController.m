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
@property (weak, nonatomic) IBOutlet UIButton *uploadOldPicTap;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIButton *bioButton;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;



@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collView.delegate = self;
    self.collView.dataSource = self;
    self.bioTextView.delegate = self;
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
        self.ppImage.file = self.user[@"image"];
    }
    else // for current user
    {
        self.screennameLabel.text = PFUser.currentUser.username;
        self.ppImage.file = PFUser.currentUser[@"image"];
    }
    [self.ppImage loadInBackground];
    //if we are not in our own profile wewon't have edit button
    if(self.user)
    {
        self.uploadOldPicTap.hidden = YES;
    }
    else {
        self.uploadOldPicTap.layer.borderWidth = 1;
        self.uploadOldPicTap.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.uploadOldPicTap.layer.cornerRadius = 8;
    }
    
    //setting the bio
    self.bioTextView.text = @"Write a bio...";
    self.bioTextView.textColor = [UIColor lightGrayColor];
    if(PFUser.currentUser[@"bio"])
    {
        self.bioTextView.text = PFUser.currentUser[@"bio"];
        self.bioTextView.textColor = [UIColor blackColor];
    }
    //for other user profiles
    if(self.user)
    {
        if(self.user[@"bio"])
        {
            self.bioLabel.text = self.user[@"bio"];
            self.bioLabel.textColor = [UIColor blackColor];
        }
    }
}


// query the posts to fill the collection view
- (void)getQuery:(UIRefreshControl *)refreshControl{
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    
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
                    //set the profile pic
                    if(self.user[@"author"][@"image"])
                    {
                        self.ppImage.file = self.user[@"author"][@"image"];
                        [self.ppImage loadInBackground];
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
                    //set the profile pic
                    if(self.postsforCurrUser.count)
                    {
                        self.ppImage.file = self.postsforCurrUser[0][@"author"][@"image"];
                        [self.ppImage loadInBackground];
                    }
                }
                NSLog(@"got 'emmmmmmmm");
                [self.collView reloadData];
                [refreshControl endRefreshing];
            }
        }
    }];
}

- (IBAction)uploadOldPicTap:(id)sender {
    BOOL oldPic = YES;
    [self choosePic:oldPic];
}

- (IBAction)uploadTap:(id)sender {
    BOOL oldPic = NO;
    [self choosePic:oldPic];
}

- (void)choosePic:(BOOL) oldPic {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && !oldPic) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead -- or you chose upload");
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
    //editedImage = [editedImage resizeImage]
    self.ppImage.image = editedImage;
    
    //save the image
    PFUser *user = PFUser.currentUser;
    user[@"image"] = [Post getPFFileFromImage:editedImage];
    [user saveInBackground];
    
    //now show the image chosen
    // load photo for current user 
    self.ppImage.file = user[@"image"];
    // if its for another user then load their photo
    if(self.user)
    {
        self.ppImage.file = self.user[@"image"];
    }
    [self.ppImage loadInBackground];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Write a bio..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        self.bioButton.hidden = NO;
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write a bio...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
- (IBAction)saveBioTap:(id)sender {
    self.bioButton.titleLabel.text = @"Edit bio";
    PFUser *user = PFUser.currentUser;
    user[@"bio"] = self.bioTextView.text;
    [user saveInBackground];
    self.bioTextView.text = user[@"bio"];
    [self.view endEditing:YES];
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
    curPost.likers = [NSMutableArray array];
    [cell settPost:curPost];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // update postsCountLabel
    self.postCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.postsforCurrUser.count];
    //actually return the number of cells
    return self.postsforCurrUser.count;
}

@end
