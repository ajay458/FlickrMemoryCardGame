//
//  UIView+Extension.m
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/21/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)hideAllChilds:(BOOL)hideOrShow
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        obj.hidden = hideOrShow;
    }];
}


@end
