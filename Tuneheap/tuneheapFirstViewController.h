//
//  tuneheapFirstViewController.h
//  Tuneheap
//
//  Created by Student on 10/11/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "sqlite3.h"


@interface tuneheapFirstViewController : UITableViewController <SPSessionPlaybackDelegate, SPSessionDelegate>{
    NSString *databasePath;
    sqlite3 *tuneheapDB;
    UIViewController *mainViewController;
}

@property(strong,nonatomic)NSString *user;
@property(strong,nonatomic)NSString *spotifyUser;
@property(strong,nonatomic)NSMutableArray *tracks;
@property(strong,nonatomic)NSMutableArray *spotifyTracks;
@property(assign,nonatomic)BOOL *notLoaded;
@property (nonatomic, strong) SPTrack *currentTrack;
@property (nonatomic, strong) SPSearch *search;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;

-(void)loadData:(NSString*)username;
-(void)grabTracksFromSpotify;
-(void)sendTracksToSpotify;

@end
