//
//  stationScreenScraper.h
//  Tuneheap
//
//  Created by Student on 10/30/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "sqlite3.h"

@interface stationScreenScraper : NSObject{
    NSMutableData *responseData;
    NSString *urlString;
    NSString *databasePath;
    sqlite3 *tuneheapDB;
}

@property(strong,nonatomic)NSMutableArray* likes;


-(id)initWithStation: (NSString *) user;
-(void)loadData;
-(void)parseData;
-(void)badUser;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)getLikes:(TBXMLElement *)element;

@end
