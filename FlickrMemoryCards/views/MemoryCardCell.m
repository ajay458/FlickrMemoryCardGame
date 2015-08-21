//
//  MemoryCardCell.m
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/20/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryCardCell.h"

@interface MemoryCardCell()

@property(nonatomic,strong)FlickrInfo *flickrInfo;


@end
@implementation MemoryCardCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoaded:) name:@"AsyncImageLoadDidFinish" object:self.flickrImageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoadingFailed:) name:@"AsyncImageLoadDidFail" object:self.flickrImageView];
    
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}


- (void)setFlickr:(FlickrInfo *)flicker
{
    self.flickrInfo = flicker;
    self.flickrImageView.imageURL = [NSURL URLWithString:[flicker.imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.flickrImageView.showActivityIndicator = NO;
    
}

- (void)imageLoaded:(NSNotification*)notification
{
    [self.delegate imageDownloadFinished:self.flickrInfo];
}

- (void)imageLoadingFailed:(NSNotification*)notification
{
    [self.delegate imageDownloadFailed:self.flickrInfo];
}

- (void)flipImage
{
    __block MemoryCardCell *cell = self;
    [UIView transitionWithView:self.contentView
                      duration:2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        cell.flickrImageView.hidden = YES;
                        cell.backgroundColor = [UIColor blueColor];
                        
                        
                    } completion:nil];
}
- (void)flipBackImage
{
    __block MemoryCardCell *cell = self;
    [UIView transitionWithView:self.contentView
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        cell.flickrImageView.hidden = NO;
                        cell.backgroundColor = [UIColor redColor];
                        
                    } completion:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end