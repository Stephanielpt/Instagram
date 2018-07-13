//
//  ComposeViewController.m
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/9/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import "ComposeViewController.h"
#import "Post.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *picToUpload;
@property (weak, nonatomic) IBOutlet UITextView *captionLabel;
@property (weak, nonatomic) IBOutlet UITextView *myUITextView;
@property (strong, nonatomic) Post *myNewPost;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoTap;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property BOOL *sharing;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myUITextView.delegate = self;
    self.myUITextView.text = @"Write a caption...";
    self.myUITextView.textColor = [UIColor lightGrayColor];
}

- (IBAction)uploadTap:(id)sender {
    BOOL oldPost = NO;
    [self choosePic:oldPost];
}

- (IBAction)uploadOldPhotoTap:(id)sender {
    BOOL oldPost = YES;
    [self choosePic:oldPost];
}


- (void)choosePic:(BOOL)oldPost {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && oldPost == NO) {
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
    self.picToUpload.image = editedImage;

    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)sharePostTap:(id)sender {
    if(self.sharing == NO)
    {
        self.sharing = YES;
        [self resizeImage:self.picToUpload.image withSize:CGSizeMake(250, 250)];
        [Post postUserImage:self.picToUpload.image withCaption:self.captionLabel.text withLocation:self.locationField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded)
            {
                NSLog(@"uploaded!");
                self.sharing = NO;
            }
            else {
                NSLog(@"could upload - sorry");
            }
            //[self performSegueWithIdentifier:@"cancelUpload" sender:nil];
            [self.tabBarController setSelectedIndex:0];
            [self dismissViewControllerAnimated:true completion:nil];
            
        }];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Write a caption..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write a caption...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (IBAction)cancelUpload:(id)sender {
    //[self performSegueWithIdentifier:@"cancelUpload" sender:nil];
    [self dismissViewControllerAnimated:true completion:nil];
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
