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

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *ppImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collView;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (strong, nonatomic) NSArray *posts;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collView.delegate = self;
    self.collView.dataSource = self;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getQuery:) forControlEvents:UIControlEventValueChanged];
    [self.collView insertSubview:refreshControl atIndex:0];
    // Do any additional setup after loading the view.
    [self getQuery:refreshControl];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.ppImage.layer.cornerRadius = 45;
}

- (void)getQuery:(UIRefreshControl *)refreshControl {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = posts;
            NSLog(@"got 'emmmmmmmm");
            [self.collView reloadData];
            [refreshControl endRefreshing];
        }
        else {
            NSLog(@"ERROR GETTING THE PARSE POSTS!");
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
    
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PostCollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collView indexPathForCell:tappedCell];
    Post *post = self.posts[indexPath.item];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.post = post;
    detailsViewController.postCell = tappedCell;
}


- (nonnull __kindof PostCollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionViewCell" forIndexPath:indexPath];
    Post * curPost = self.posts[indexPath.item];
    //postCollCell *cell;
    [cell settPost:curPost];
    //return cell;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}

@end
