//
//  MemoryModel.h
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/18/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"


@interface FlickrInfo : MTLModel<MTLJSONSerializing>
@property(nonatomic,copy)NSString *imageUrl;
@property(nonatomic,assign)BOOL isLoaded;
@property(nonatomic,assign)BOOL invalidate;
@end


@interface MemoryModel : NSObject

+ (MemoryModel*)sharedInstance;

- (void)fetchFlickrImages:(NSUInteger)imagecount withCompletionHandler:(void (^)(NSArray*,NSString*))onComplete;

- (NSArray*)modelInfo;

@end