//
//  WebServices.m
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/18/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServices.h"
#import <AFNetworking/AFNetworking.h>



@implementation WebServices

+(WebServices*)sharedWebServices{
    
    static WebServices *sharedInstance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)fetchDataWithBlock:(void(^)(NSData*,NSString*))callback {
    
    NSString *urlString = @"https://api.flickr.com/services/feeds/photos_public.gne?format=json&lang=en-us";//@"https://api.flickr.com/services/feeds/photos_public.gne";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *rawString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange initialRange = [rawString rangeOfString:@"jsonFlickrFeed("];
        NSRange finalRange = [rawString rangeOfString:@"})"];
        NSRange range = NSMakeRange(initialRange.location + initialRange.length, finalRange.location - initialRange.location - initialRange.length+1);
        NSString *refinedString = [rawString substringWithRange:range];
        refinedString = [self xmlSimpleEscape:refinedString];

        NSData *responseData = [refinedString dataUsingEncoding:NSUTF8StringEncoding];
        callback(responseData,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil,[error localizedDescription]);
        
    }];
        
    [operation start];
    
}


- (NSMutableString *)xmlSimpleEscape:(NSString*)requiredString1
{
    NSMutableString *requiredString = [requiredString1 mutableCopy];
    //requiredString = [[requiredString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];

    [requiredString replaceOccurrencesOfString:@"\\\'"  withString:@" "   options:NSLiteralSearch range:NSMakeRange(0, [requiredString length])];
    //[requiredString replaceOccurrencesOfString:@"\\"  withString:@""   options:NSLiteralSearch range:NSMakeRange(0, [requiredString length])];

    
    
    return requiredString;
}


@end