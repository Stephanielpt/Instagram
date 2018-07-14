//
//  HomeViewController.m
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/9/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import "HomeViewController.h"
#import "postCell.h"
#import "Post.h"
#import "ProfileViewController.h"
#import "DateTools.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSString *createdAtString;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation HomeViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    [self getQuery:self.refreshControl infiniteScroll:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Fill the array of posts
    [self getQuery:self.refreshControl infiniteScroll:NO];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 800;
    [self getQuerySetUpRefreshControl:self.refreshControl];
}

// set up for the refresh controller
- (void)getQuerySetUpRefreshControl:(UIRefreshControl *)refreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getQuery: infiniteScroll:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

// call parse to set posts array
- (void)getQuery:(UIRefreshControl *)refreshControl infiniteScroll:(BOOL)infinite{
//    [self getQuerySetUpRefreshControl:self.refreshControl];
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"likers"];
    postQuery.limit = 20;
    if(infinite)
    {
        postQuery.skip = self.posts.count;
    }
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if(error != nil)
        {
            NSLog(@"ERROR GETTING THE PARSE POSTS!");
        }
        else {
            if (posts) {
                if(!infinite)
                {
                    self.posts = [[NSMutableArray alloc] init];
                }
                for(Post *newPost in posts)
                {
                    [self.posts addObject:newPost];
                }
                //self.posts = posts;
                NSLog(@"got 'em");
                [self.tableView reloadData];
                if (refreshControl) {
                    [refreshControl endRefreshing];
                }
            }
        }
    }];
}

// necessities for tableview
- (nonnull PostCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // set the cell's simple properties
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell"];
    Post * curPost = self.posts[indexPath.row];
    cell.captionLabel.text = curPost.caption;
    cell.screennameLabel.text = curPost.author.username;
    // TODO: Format and set createdAtString
    NSDate *date = curPost.createdAt;
    // Convert Date to String
    NSString *timeAgoDate = [NSDate shortTimeAgoSinceDate:date];
    curPost.createdAtString = timeAgoDate;
    // call settPost to set the cell's PFImage views
    [cell settPost:curPost];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}


// triggers for infinite scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            
            // ... Code to load more results ...
//            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//            [refreshControl addTarget:self action:@selector(getQuery: infiniteScroll:) forControlEvents:UIControlEventValueChanged];
//            [self.tableView insertSubview:refreshControl atIndex:0];
//
            [self getQuery:self.refreshControl infiniteScroll:YES];
        }
    }
}

// to logout
- (IBAction)logoutTap:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
    [self performSegueWithIdentifier:@"logoutSegue" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"otherUserSegue"])
    {
        ProfileViewController *profileViewController = [segue destinationViewController];
        PostCell *tappedCell = sender;
        
        profileViewController.user = tappedCell.post.author;
    }
    // Pass the selected object to the new view controller.
}

@end
