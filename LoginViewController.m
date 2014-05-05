//
//  LoginViewController.m
//  Tuneheap
//
//  Created by Student on 10/11/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import "LoginViewController.h"
#import "tuneheapFirstViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize loaded;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


//Create initial table for users and databse
- (void)viewDidLoad
{
    [super viewDidLoad];
    spinner.hidesWhenStopped = YES;
    [loginButton setHidden:YES];
    foundUser = @"";
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex: 0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"tuneheap.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if([filemgr fileExistsAtPath:databasePath] == NO){
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS USERS (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER TEXT)";
            if (sqlite3_exec(tuneheapDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK ) {
                NSLog(@"Failed to create table %s",errMsg);
            }
            sqlite3_close(tuneheapDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
        
    }
	const char *dbpath =[databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK ) {
        int last = [self getLastLocationId];
        NSString *querySQL = [NSString stringWithFormat:@"SELECT user FROM USERS WHERE ID = %d",last];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare(tuneheapDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *user = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSLog(@"Found user %@",user);
                foundUser = user;
                loginText.text = user;
                
            } else {
                NSLog(@"No user found");
            }
            sqlite3_finalize(statement);
        }else{
            NSLog(@"SQL not OK");
        }
        sqlite3_close(tuneheapDB);
    }
    if(loginText.text != @""){
        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
        //[self login:nil];
    }
}

-(int)getLastLocationId{
    NSString *sqlNsStr = [NSString stringWithFormat:@"SELECT * FROM USERS"];
    const char *sql = [sqlNsStr UTF8String];
    sqlite3_stmt *statement;
    int lastrec=0;
    const char *dbpath =[databasePath UTF8String];
    if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK) {
        sqlite3_prepare(tuneheapDB, sql, -1, &statement, NULL);
        while(sqlite3_step(statement) == SQLITE_ROW) {
            lastrec = sqlite3_column_int(statement, 0);
        }
        sqlite3_reset(statement);
    }
    return lastrec;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Query pandora for the given username if no tracks already exist.
-(IBAction)query:(id)sender{
    [spinner startAnimating];
    [self.view endEditing:YES];
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex: 0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"tuneheap.db"]];
    const char *dbpath =[databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK ) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT TRACK TEXT FROM TRACKS"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare(tuneheapDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while(true){
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    NSString *track = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    NSLog(@"Found track %@",track);
                    [spinner stopAnimating];
                    [loginButton setHidden:NO];
                    [queryButton setHidden:YES];
                    return;
                } else {
                    NSLog(@"No tracks found");
                    break;
                }
            }
            sqlite3_finalize(statement);
        }else{
            NSLog(@"SQL not OK");
        }
        sqlite3_close(tuneheapDB);
    }
    screenScraper *scraper = [[screenScraper alloc]initWithUser:loginText.text];
    [scraper loadData];
    [spinner stopAnimating];
    [loginButton setHidden:NO];
    [queryButton setHidden:YES];
}

//Insert into database if user does not exist, then segue to tab view controller
-(IBAction)login:(id)sender{
    
    NSLog(@"Logging in with: %@",loginText.text);
    sqlite3_stmt *statement;
    const char *dbpath =[databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK && foundUser != loginText.text) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO USERS (user) VALUES (\"%@\")", loginText.text];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare(tuneheapDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Saved user %@",loginText.text);
        } else {
            NSLog(@"Failed to add contact");
        }
        sqlite3_finalize(statement);
        sqlite3_close(tuneheapDB);
    }
    
    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"LoginSegue"]){
        tuneheapFirstViewController *fvc = (tuneheapFirstViewController *)[segue destinationViewController];
        fvc.user = loginText.text;
        [self presentViewController:fvc animated:YES completion:nil];
    }
}

@end
