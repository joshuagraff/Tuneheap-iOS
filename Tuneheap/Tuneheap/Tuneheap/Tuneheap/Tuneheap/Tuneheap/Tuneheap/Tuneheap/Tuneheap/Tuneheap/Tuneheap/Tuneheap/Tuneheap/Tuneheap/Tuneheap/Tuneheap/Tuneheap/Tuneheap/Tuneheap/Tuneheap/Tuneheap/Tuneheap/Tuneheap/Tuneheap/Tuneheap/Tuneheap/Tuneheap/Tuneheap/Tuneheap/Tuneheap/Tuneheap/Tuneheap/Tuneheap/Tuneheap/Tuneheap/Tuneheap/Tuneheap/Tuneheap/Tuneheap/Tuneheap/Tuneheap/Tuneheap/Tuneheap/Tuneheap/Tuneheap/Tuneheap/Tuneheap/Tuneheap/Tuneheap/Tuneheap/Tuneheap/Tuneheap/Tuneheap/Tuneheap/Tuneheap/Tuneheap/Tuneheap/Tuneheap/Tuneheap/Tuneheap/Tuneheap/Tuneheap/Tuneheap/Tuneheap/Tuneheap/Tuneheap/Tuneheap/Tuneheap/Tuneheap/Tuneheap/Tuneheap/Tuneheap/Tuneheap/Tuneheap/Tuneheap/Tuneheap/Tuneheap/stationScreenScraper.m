//
//  stationScreenScraper.m
//  Tuneheap
//
//  Created by Student on 10/30/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import "stationScreenScraper.h"

@implementation stationScreenScraper

@synthesize likes;

-(id)init
{
    self = [super init];
    if(self){
        likes = [[NSMutableArray alloc] init];
        //urlString = @"http://www.pandora.com/favorites/profile_tablerows_station.vm?webname=mongoose777121";
    }
    return self;
}

-(id)initWithStation:(NSString *)station{
    self = [super init];
    if(self){
        likes = [[NSMutableArray alloc] init];
        //urlString = @"http://people.rit.edu/bdfvks/542/plates/plates.php?type=plist";
        urlString = [NSString stringWithFormat:@"http://www.pandora.com/favorites/station_tablerows_thumb_up.vm?token=%@&sort_col=thumbsUpDate",station];
        NSLog(@"Station URL: %@",urlString);
        NSString *docsDir;
        NSArray *dirPaths;
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex: 0];
        databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"tuneheap.db"]];
        NSFileManager *filemgr = [NSFileManager defaultManager];
            const char *dbpath = [databasePath UTF8String];
            if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK) {
                char *errMsg;
                const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TRACKS (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRACK TEXT)";
                if (sqlite3_exec(tuneheapDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK ) {
                    NSLog(@"Failed to create table %s",errMsg);
                }
                sqlite3_close(tuneheapDB);
            } else {
                NSLog(@"Failed to open/create database");
            }
            
        
    }
    return self;
}

-(void)loadData{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection){
        responseData = [NSMutableData data];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    }else{
        [self badUser];
    }
    NSLog(@"connection=%@",connection);
}

-(NSMutableArray*)parseData{
    TBXML *xmlData = [[TBXML alloc] initWithXMLData:responseData error:nil];
    //TBXML *xmlData = [TBXML tbxmlWithURL:[NSURL URLWithString:urlString]];
    //TBXMLElement *tr = [TBXML childElementNamed:@"tr" parentElement:xmlData.rootXMLElement];
    //[self traverseElement:xmlData.rootXMLElement];
    if(xmlData.rootXMLElement){
         NSLog(@"Getting data from URL: %@",urlString);
        [self getLikes:xmlData.rootXMLElement];
        sqlite3_stmt *statement;
        const char *dbpath =[databasePath UTF8String];
        for(int i =0; i<likes.count;i++){
            if (sqlite3_open(dbpath, &tuneheapDB) == SQLITE_OK) {
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO TRACKS (track) VALUES (\"%@\")", [likes objectAtIndex:i]];
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare(tuneheapDB, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE) {
                    NSLog(@"Saved track %@",[likes objectAtIndex:i]);
                } else {
                    NSLog(@"Failed to add track");
                }
                sqlite3_finalize(statement);
                sqlite3_close(tuneheapDB);
            }
        }

    }
    return likes;
}

-(void)getLikes:(TBXMLElement *)element{
    do {
        if([[TBXML elementName:element] isEqualToString:@"span"]){
            // Display the name of the element
            //NSLog(@"%@",[TBXML elementName:element]);
            
            // Obtain first attribute from element
            TBXMLAttribute * attribute = element->firstAttribute;
            
            // if attribute is valid
            while (attribute) {
                // Display name and value of attribute to the log window
                NSLog(@"%@->%@ = %@",
                      [TBXML elementName:element],
                      [TBXML attributeName:attribute],
                      [TBXML attributeValue:attribute]);
                
                if([[TBXML attributeName:attribute] isEqualToString:@"trackTitle"]){
                    NSString *title = [TBXML attributeValue:attribute];
                    TBXMLElement *nextsibling = element->parentElement->nextSibling;
                    TBXMLElement * anchor = [TBXML childElementNamed:@"a" parentElement:nextsibling];
                    NSString * artist = [TBXML textForElement:anchor];
                    [likes addObject:[NSString stringWithFormat:@"%@ %@",title,artist]];
                    return;
                }
                // Obtain the next attribute
                attribute = attribute->next;
            }
        }
        
        // if the element has child elements, process them
        if (element->firstChild)
            [self getLikes:element->firstChild];
        
        // Obtain next sibling element
    } while ((element = element->nextSibling));
    
}


#pragma mark -
#pragma mark NSURLConnection delegate methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"didRecieveResponse response = %@",httpResponse);
    NSLog(@"status code = %d",[httpResponse statusCode]);
    if(httpResponse.statusCode != 200){
        [connection cancel];
        return;
    }
    NSLog(@"headers = %@",[httpResponse allHeaderFields]);
    NSString *lastModStr = [[httpResponse allHeaderFields] objectForKey:@"Last-Mod"];
    
    NSLog(@"last-mod date=%@",[NSDate dateWithTimeIntervalSince1970:[lastModStr floatValue]]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //NSLog(@"diddRecieveData - data=%@",data);
    NSString *string = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    //NSLog(@"didRecieveData - data to string = %@",string);
    [responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"didFailWithError error = %@",error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [self parseData];
}

@end
