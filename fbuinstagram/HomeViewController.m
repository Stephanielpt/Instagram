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

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *posts;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getQuery:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    // FILL THE ARRAY OF POSTS
    [self getQuery:refreshControl];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 600;
    
    // Do any additional setup after loading the view.
    
    NSLog(@"hopefully here last");
    //[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
}

//- (void)onTimer {
//    [self.tableView reloadData];
//}

- (void)getQuery:(UIRefreshControl *)refreshControl {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = posts;
            NSLog(@"got 'em");
            [self.tableView reloadData];
            [refreshControl endRefreshing];
        }
        else {
            NSLog(@"ERROR GETTING THE PARSE POSTS!");
        }
    }];
}
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull PostCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell"];
    //cell.delegate = self;

    Post * curPost = self.posts[indexPath.row];
    cell.captionLabel.text = curPost.caption;
    //cell.postedImage.image = curPost.image;
    cell.screennameLabel.text = curPost.author.username;
//    cell.ppImage = curPost.userID;
//    cell.locationLabel = curPost.
    //[cell setPost:curPost];
    [cell settPost:curPost];
    NSLog(@"hopefully here first");
//    cell.frame.size.height = CGRectMake(cell.frame.origin.x, cell.frame.origin.x, cell.frame.size.width, 50);

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}


@end
