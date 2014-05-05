//
//  tuneheapFirstViewController.m
//  Tuneheap
//
//  Created by Student on 10/11/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import "tuneheapFirstViewController.h"
#include "appkey.c"


@interface tuneheapFirstViewController ()

@end

@implementation tuneheapFirstViewController

@synthesize user,spotifyUser,tracks,notLoaded,spotifyTracks;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setNotLoaded:NO];
    }
    return self;
}
			

//Grabs all tracks in the database
- (void)viewDidLoad
{
    [super viewDidLoad];
    tracks = [[NSMutableArray alloc]init];
    spotifyTracks = [[NSMutableArray alloc]init];
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
                    [tracks addObject:track];
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
    
    
        
}


-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error{
    //[self setLoaded:NO];
}

//Perform Spotify login if needed
-(void)viewDidAppear:(BOOL)animated
{
    if(notLoaded){
        [self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
        [self setNotLoaded:NO];
    }else{
        [self grabTracksFromSpotify];
    }
}

//On getting credentials back, save them for next time
-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *storedCredentials = [[defaults valueForKey:@"SpotifyUsers"] mutableCopy];
    if(storedCredentials==nil){
        storedCredentials = [[NSMutableArray alloc]init];
    }
    [storedCredentials addObject:userName];
    [storedCredentials addObject:credential];
    [defaults setValue:storedCredentials forKey:@"SpotifyUsers"];
    [self.tableView reloadData];
}

//Load data if saved, otherwise set need to login flag
-(void)loadData:(NSString*)username{
    user = username;
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"com.spotify.TuneHeap"
										   loadingPolicy:SPAsyncLoadingManual
												   error:nil];
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    
    [self addObserver:self forKeyPath:@"search.tracks" options:0 context:nil];
    
    [[SPSession sharedSession] setDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *storedCredentials = [[defaults valueForKey:@"SpotifyUsers"] mutableCopy];
    
    if(storedCredentials==nil){
        [self setNotLoaded:YES];
    }else{
        spotifyUser = [storedCredentials objectAtIndex:0];
    }
    
    [[SPSession sharedSession] attemptLoginWithUserName:[storedCredentials objectAtIndex:0] existingCredential:[storedCredentials objectAtIndex:1]];
    
    NSLog(@"User : %@",user);
    
}


//Show the login controller
-(void)showLogin {
    
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	controller.allowsCancel = NO;
	
	[self.navigationController presentModalViewController:controller animated:NO];
    
}

//For returned search queries, save Tracks
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"search.tracks"]){
        if(self.search.tracks.count >0){
            SPTrack *curTrack = (SPTrack*)[self.search.tracks objectAtIndex:0];
            NSLog(@"Search found tracks: %@", curTrack);
            
        }else{
            NSLog(@"No tracks found");
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *curTrack = [tracks objectAtIndex:indexPath.row];
    NSLog(@"Track at %d is %@",indexPath.row,curTrack);
    cell.textLabel.text = curTrack;
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}


//Search Spotify for each track, save those tracks to an array using Async loading
-(void)grabTracksFromSpotify{
    if(spotifyTracks.count ==0){
        for(NSString *track in tracks){
            self.search = [SPSearch searchWithSearchQuery:track inSession:[SPSession sharedSession]];
            [SPAsyncLoading waitUntilLoaded:self.search timeout:10.0 then:^(NSArray *loadedTracks, NSArray *notLoadedTracks) {
                
                if(loadedTracks.count>0){
                    SPSearch *curSearch = (SPSearch*)[loadedTracks objectAtIndex:0];
                    if(curSearch.tracks.count >0){
                        NSLog(@"The following were loaded: %@",[[curSearch tracks]objectAtIndex:0]);
                        [spotifyTracks addObject:[[curSearch tracks]objectAtIndex:0]];
                    }
                }
            }];
            
        }
    }
}

//Send an array of Spotify tracks to the current user
-(void)sendTracksToSpotify{
    for(SPTrack *track in spotifyTracks){
        NSLog(@"Sending : %@ to %@",track,[SPSession sharedSession].user.displayName);
    }
    [[SPSession sharedSession] postTracks:spotifyTracks toInboxOfUser:[SPSession sharedSession].user.displayName withMessage:@"This is a test!" callback:nil];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
