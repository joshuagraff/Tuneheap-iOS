//
//  tuneheapTabVC.m
//  Tuneheap
//
//  Created by Student on 11/1/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import "tuneheapTabVC.h"

@interface tuneheapTabVC ()

@end

@implementation tuneheapTabVC

@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Creating Tab VC %@",user);
    UINavigationController *nav = (UINavigationController*)[[self viewControllers] objectAtIndex:0];
    
    tuneheapFirstViewController *fvc = [nav.viewControllers objectAtIndex:0];
    tuneheapSecondViewController *svc = [[self viewControllers] objectAtIndex:1];
    svc.title = NSLocalizedString(@"Send Playlist", @"Send Playlist");
    svc.tabBarItem.image = [UIImage imageNamed:@"40-inbox.png"];
    fvc.title = NSLocalizedString(@"Songs", @"Songs");
    fvc.tabBarItem.image = [UIImage imageNamed:@"65-note.png"];
    svc.user = user;
    svc.fvc = fvc;
    [svc loadData];
    [fvc loadData:user];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
