//
//  LoginViewController.h
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/23/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end
