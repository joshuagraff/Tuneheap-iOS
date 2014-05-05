//
//  LoginViewController.h
//  Tuneheap
//
//  Created by Student on 10/11/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "screenScraper.h"

@interface LoginViewController : UIViewController{
    IBOutlet UITextField *loginText;
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *queryButton;
    IBOutlet UIActivityIndicatorView *spinner;
    NSString *databasePath;
    sqlite3 *tuneheapDB;
    NSString *foundUser;
}

@property(assign,nonatomic)BOOL loaded;

-(IBAction)login:(id)sender;
-(IBAction)query:(id)sender;

-(int)getLastLocationId;

@end
