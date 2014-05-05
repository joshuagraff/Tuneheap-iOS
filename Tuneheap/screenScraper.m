//
//  screenScraper.m
//  Tuneheap
//
//  Created by MacUser on 10/27/12.
//  Copyright (c) 2012 Josh Graff. All rights reserved.
//

#import "screenScraper.h"

@implementation screenScraper

@synthesize stations,likes;

-(id)init
{
    self = [super init];
    if(self){
        stations = [[NSMutableArray alloc] init];
        urlString = @"http://www.pandora.com/favorites/profile_tablerows_station.vm?webname=mongoose777121";
    }
    return self;
}

-(id)initWithUser:(NSString *)user{
    self = [super init];
    if(self){
        stations = [[NSMutableArray alloc] init];
        urlString = [NSString stringWithFormat:@"http://www.pandora.com/favorites/profile_tablerows_station.vm?webname=%@",user];
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

-(void)parseData{
    if(stations.count==0){
        TBXML *xmlData = [[TBXML alloc] initWithXMLData:responseData error:nil];
        [self getStations:xmlData.rootXMLElement];
        NSMutableArray *stationScrapers = [[NSMutableArray alloc]init];
        NSLog(@"Station count: %d",stations.count);
        for(NSString* station in stations){
            //responseData = [NSMutableData data];
            stationScreenScraper *stationPage = [[stationScreenScraper alloc]initWithStation:station];
            [stationPage loadData];
            [stationScrapers addObject:stationPage];
            
        }
    }
    
    
}


- (void) getStations:(TBXMLElement *)element {
    do {
        if([[TBXML elementName:element] isEqualToString:@"a"]){
            // Display the name of the element
            //NSLog(@"%@",[TBXML elementName:element]);
            
            // Obtain first attribute from element
            TBXMLAttribute * attribute = element->firstAttribute;
            
            // if attribute is valid
            while (attribute) {
                // Display name and value of attribute to the log window
                
                if([[TBXML attributeName:attribute] isEqualToString:@"href"]){
                    NSString *url = [TBXML attributeValue:attribute];
                    if([url rangeOfString:@"/stations/"].location == NSNotFound){
                        break;
                    }else{
                        url = [url stringByReplacingOccurrencesOfString:@"/stations/" withString:@""];
                        [stations addObject:url];
                        NSLog(@"added: %@",[TBXML attributeValue:attribute]);
                    }
                }
                // Obtain the next attribute
                attribute = attribute->next;
            }
        }
        
        // if the element has child elements, process them
        if (element->firstChild)
            [self getStations:element->firstChild];
        
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
