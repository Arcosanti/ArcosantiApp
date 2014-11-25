//
//  LoginViewController.m
//  arcosanti
//
//  Created by Jeff Kunzelman on 11/23/14.
//  Copyright (c) 2014 Jeffrey Kunzelman. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        NSLog (@"Login Successful");
    } else {
        // show the signup or login screen
        [self loginUserWithLogin:@"testor" password:@"testuser"];
    }
    
    
    
    
    
    
    
    
}

-(void)loginUserWithLogin:(NSString *)login password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:login password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                            NSLog (@"Login Successful %@",[error userInfo][@"error"]);
                                        } else {
                                            NSString *errorString = [error userInfo][@"error"];
                                                    // Show the errorString somewhere and let the user try again.
                                            NSLog (@"Login Error %@",errorString);
                                            
                                            [self createUserWithLogin:@"testor" password:@"testuser"];
                                            
                                        
                                        }
                                    }];
}

-(void)createUserWithLogin:(NSString *)login password:(NSString *)password
{
    // Do any additional setup after loading the view.
    PFUser *user = [PFUser user];
    user.username = login;
    user.password = password;
    user.email = @"jeff@river.io";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            NSLog (@"Login Created! %@",[error userInfo][@"error"]);
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
        }
    }];

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
