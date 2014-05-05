//
//  tuneheapSecondViewController.h
//  Tuneheap
//
//  Created by Student on 10/11/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"
#import "screenScraper.h"
#import "tuneheapFirstViewController.h"

@interface tuneheapSecondViewController : UIViewController{
    IBOutlet UITextView *textView;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIButton *sendTracks;
    IBOutlet UILabel *label;
    NSMutableData *responseData;
    NSString *urlString;
}

@property(strong,nonatomic)NSMutableArray* stations;
@property(strong,nonatomic)NSMutableArray* likes;
@property(strong,nonatomic)screenScraper* scraper;
@property(strong,nonatomic)NSString* user;
@property(strong,nonatomic)tuneheapFirstViewController* fvc;

-(IBAction)buttonClicked:(id)sender;
-(IBAction)sendPlaylist:(id)sender;
-(void)loadData;
-(void)parseData;
-(void)badUser;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)getStations:(TBXMLElement *)element;
-(void)getLikes:(TBXMLElement *)element;


@end
