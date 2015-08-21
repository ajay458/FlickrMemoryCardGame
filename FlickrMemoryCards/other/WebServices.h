//
//  WebServices.h
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/18/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

@interface WebServices : NSObject

+(WebServices*)sharedWebServices;

- (void)fetchDataWithBlock:(void(^)(NSData*,NSString*))callback;

@end