//
//  MemoryCardCell.h
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/20/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MemoryModel.h"


@protocol MemoryCardCellDelegate <NSObject>

- (void)imageDownloadFinished:(FlickrInfo*)flickrInfo;
- (void)imageDownloadFailed:(FlickrInfo*)flickrInfo;

@end

@interface MemoryCardCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet AsyncImageView *flickrImageView;
@property(nonatomic,weak)id<MemoryCardCellDelegate>delegate;
@property(nonatomic,assign)BOOL invalidate;

- (void)setFlickr:(FlickrInfo*)flicker;

- (void)flipImage;
- (void)flipBackImage;

@end