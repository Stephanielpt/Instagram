//
//  ProfileViewController.h
//  fbuinstagram
//
//  Created by Stephanie Lampotang on 7/10/18.
//  Copyright © 2018 Stephanie Lampotang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
// only when segueing to other profiles
@property (strong, nonatomic) PFUser *user;

@end
