//
//  screenScraper.h
//  Tuneheap
//
//  Created by MacUser on 10/27/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "stationScreenScraper.h"

@interface screenScraper : NSObject{
    NSMutableData *responseData;
    NSString *urlString;
}

@property(strong,nonatomic)NSMutableArray* stations;
@property(strong,nonatomic)NSMutableArray* likes;


-(id)initWithUser: (NSString *) user;
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
