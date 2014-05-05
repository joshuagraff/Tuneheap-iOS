//
//  tuneheapSecondViewController.m
//  Tuneheap
//
//  Created by Student on 10/11/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import "tuneheapSecondViewController.h"

@interface tuneheapSecondViewController ()

@end

@implementation tuneheapSecondViewController

@synthesize stations,scraper,user,fvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(IBAction)buttonClicked:(id)sender{
    //[self loadData];
    [spinner startAnimating];
    [scraper loadData];
    [spinner stopAnimating];
}

-(IBAction)sendPlaylist:(id)sender{
    [spinner startAnimating];
    [fvc sendTracksToSpotify];
    [label setText:[NSString stringWithFormat:@"Playlist sent to your spotify account"]];
    [spinner stopAnimating];
}

-(void)loadData{
    stations = [[NSMutableArray alloc] init];
    urlString = [NSString stringWithFormat:@"http://www.pandora.com/favorites/profile_tablerows_station.vm?webname=%@",user];
}


@end
