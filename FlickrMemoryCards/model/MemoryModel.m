//
//  MemoryModel.m
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/18/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryModel.h"
#import "WebServices.h"

@implementation FlickrInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"imageUrl": @"media.m"};
}

@end

typedef void (^OnModelReady)(NSArray*,NSString*);


@interface MemoryModel()<NSXMLParserDelegate>

@property(nonatomic,strong)NSArray *modelInfoArray;
@property(nonatomic,strong)NSXMLParser *parser;
@property(nonatomic,copy)OnModelReady modelReady;




@end




@implementation MemoryModel

+ (MemoryModel*)sharedInstance{
    
    static MemoryModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    if(self = [super init]) {
        
        self.modelInfoArray = [[NSMutableArray alloc] initWithCapacity:1];
        
    }
    
    return self;

}


- (void)fetchFlickrImages:(NSUInteger)imagecount withCompletionHandler:(OnModelReady)onComplete{
    
    __weak MemoryModel *weakSelf = self;
    self.modelReady = onComplete;
    
    [[WebServices sharedWebServices] fetchDataWithBlock:^(NSData *response,NSString *errorMessage){
        
        if(response){
            
//            weakSelf.parser = [[NSXMLParser alloc] initWithData:response];
//            weakSelf.parser.delegate = self;
//            [weakSelf.parser parse];
            
            NSDictionary *jsonObject=[NSJSONSerialization
                                      JSONObjectWithData:response
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
            NSError *parseError = nil;
            self.modelInfoArray = [MTLJSONAdapter modelsOfClass:[FlickrInfo class] fromJSONArray:jsonObject[@"items"] error:&parseError];
            NSLog(@"object = %@",self.modelInfoArray);
             self.modelReady(self.modelInfoArray,nil);

        }
        else
        {
            weakSelf.modelReady(nil,errorMessage);
        }
        
        
    }];
}


- (BOOL)isStringEndsWithImageExtenstion:(NSString*)href
{
    return [href hasSuffix:@"png"] || [href hasSuffix:@"jpg"];
    
}
#pragma mark NSXMLParser Delegate
- (void)parser:(nonnull NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict
{
    if([elementName isEqualToString:@"link"])
    {
        NSString *imageUrl = attributeDict[@"href"];
        BOOL isAttributesSatisfied = [attributeDict[@"type"] isEqualToString:@"image/jpeg"] && [self isStringEndsWithImageExtenstion:imageUrl];
        if(isAttributesSatisfied)
        {
            FlickrInfo *flickrInfo = [[FlickrInfo alloc] init];
            flickrInfo.imageUrl = imageUrl;
           // [self.modelInfoArray addObject:flickrInfo];
            
            
        }
    }
}

- (void)parserDidStartDocument:(nonnull NSXMLParser *)parser
{
    //[self.modelInfoArray removeAllObjects];
    
}
- (void)parserDidEndDocument:(nonnull NSXMLParser *)parser
{
    self.modelReady(self.modelInfoArray,nil);
}

- (void)parser:(nonnull NSXMLParser *)parser parseErrorOccurred:(nonnull NSError *)parseError
{
    self.modelReady(nil,[parseError localizedDescription]);
}


- (NSArray*)modelInfo
{
    return self.modelInfoArray;
}

@end