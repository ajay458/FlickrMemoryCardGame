//
//  ViewController.m
//  FlickrMemoryCards
//
//  Created by AjayKumar.Pasumarthi on 8/18/15.
//  Copyright © 2015 AjayKumar.Pasumarthi. All rights reserved.
//

#import "ViewController.h"
#import "MemoryModel.h"
#import "MemoryCardCell.h"
#import "UIView+Extension.h"


typedef enum {
    PlayStateOff,
    PlayStatePlaying,
    PlayStatePaused,
} PlayState;


@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,MemoryCardCellDelegate>

@property(nonatomic,weak)IBOutlet UICollectionView *memoryGameCollectionView;
@property(nonatomic,weak)IBOutlet UILabel *timerLabel;
@property(nonatomic,weak)IBOutlet AsyncImageView *questionView;
@property(nonatomic,weak)IBOutlet UIButton *resetButton;
@property(nonatomic,weak)IBOutlet UIButton *freshGameButton;
@property(nonatomic,weak)IBOutlet UIButton *startGameButton;
@property(nonatomic,strong)NSArray *modelInfoArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityloader;
@property(nonatomic,strong)NSTimer *gameTimer;
@property(nonatomic,assign)NSInteger randomIndex;
@property(nonatomic,assign)BOOL isAllImagesLoaded;
@property(nonatomic,assign)NSUInteger countdown;
@property(nonatomic,assign)PlayState playState;


@end

const NSUInteger NumberOfCards = 9;
const NSUInteger TimeToShow = 15.0;

@implementation ViewController

#pragma mark ViewController Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.memoryGameCollectionView registerNib:[UINib nibWithNibName:@"MemoryCardCell" bundle:nil] forCellWithReuseIdentifier:@"cardCell"];
    self.playState = PlayStateOff;
    [self changeGameAction:self.startGameButton];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeGameAction:(id)sender
{
    UIButton *actionButton = (UIButton*)sender;
    if([actionButton isEqual:self.startGameButton])
    {
        [self fetchFlickrDataWithCount:NumberOfCards];
        [self hideOrShowStartGameButton:YES];
        
    }
    else if ([actionButton isEqual:self.resetButton])
    {
        
    }
    else if ([actionButton isEqual:self.freshGameButton])
    {
        
    }
    
}


#pragma mark -
#pragma mark Support methods

- (MemoryModel*)model{
    return [MemoryModel sharedInstance];
}


- (void)fetchFlickrDataWithCount:(NSUInteger)requiredImagesCount {
    __weak ViewController *weakSelf = self;
    [self.activityloader startAnimating];

    [self.model fetchFlickrImages:requiredImagesCount withCompletionHandler:^(NSArray *flickrInfoArray, NSString *error) {
        
        if(flickrInfoArray){
            weakSelf.modelInfoArray = flickrInfoArray.count > NumberOfCards ? [flickrInfoArray subarrayWithRange:NSMakeRange(0, NumberOfCards)] : flickrInfoArray;
            [weakSelf.memoryGameCollectionView reloadData];
            weakSelf.randomIndex = rand() % weakSelf.modelInfoArray.count;
        }
        else
        {
            weakSelf.modelInfoArray = nil;
            [weakSelf.memoryGameCollectionView reloadData];
            [weakSelf.activityloader stopAnimating];

        }
        
    }];
}


#pragma mark UICOllectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.modelInfoArray count];
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cardCell";
    MemoryCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setFlickr:[self.modelInfoArray objectAtIndex:indexPath.row]];
    return cell;
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.memoryGameCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.memoryGameCollectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (NumberOfCards/3 - 1);
    CGFloat availableHeightForCells = CGRectGetWidth(self.memoryGameCollectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (NumberOfCards/3 - 1);
    CGFloat cellWidth = availableWidthForCells / 3;
    CGFloat cellHeight = availableHeightForCells/3;
    flowLayout.itemSize = CGSizeMake(cellWidth-10, cellHeight+20);
    return flowLayout.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

#pragma mark UICOllectionViewDelegate


- (void)collectionView:(nonnull UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(self.randomIndex == indexPath.row)
    {
        MemoryCardCell *cell = (MemoryCardCell*)[self.memoryGameCollectionView cellForItemAtIndexPath:indexPath];
        FlickrInfo *info = [self.modelInfoArray objectAtIndex:indexPath.row];
        info.invalidate = YES;
        [cell flipBackImage];
        self.randomIndex = [self getRandomIndex];
        if(self.randomIndex>0)
        {
            [self updateQuestionView];

        }
    }
    
}


#pragma mark randomIndex

-(NSInteger)getRandomIndex {
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF.invalidate==%@",@(NO)];
    NSArray *filterArray = [self.modelInfoArray filteredArrayUsingPredicate:filterPredicate];
    
    if(filterArray.count>0)
    {
        NSUInteger randomValue = rand() % filterArray.count;
        FlickrInfo *info = [filterArray objectAtIndex:randomValue];
        __block NSUInteger randomIndex = -1;
        [self.modelInfoArray enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
            FlickrInfo *actualFlipInfo = (FlickrInfo*)obj;
            if([info.imageUrl isEqualToString:actualFlipInfo.imageUrl])
            {
                randomIndex = idx;
                *stop = YES;
            }
        }];
        
        
        return  randomIndex;
    }
    else
    {
        return -1;
    }
  
}


#pragma mark MemoryCardDelegate

- (void)imageDownloadFailed:(FlickrInfo *)flickrInfo
{
    
    self.isAllImagesLoaded = NO;
    
}

- (void)imageDownloadFinished:(FlickrInfo *)flickrInfo
{
     __weak ViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^{
        flickrInfo.isLoaded = YES;
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF.isLoaded==%@",@(NO)];
        NSArray *unLoadedObjectArray = [weakSelf.modelInfoArray filteredArrayUsingPredicate:filterPredicate];
        if(unLoadedObjectArray.count==0)
        {
            weakSelf.isAllImagesLoaded = YES;
            [weakSelf startGameLogic];
            
        }
    });
}

#pragma mark Support
- (void)startGameLogic
{
    [self.view hideAllChilds:NO];
    [self hideOrShowStartGameButton:YES];
    [self.activityloader stopAnimating];
    self.countdown = TimeToShow;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02lu", 0, (unsigned long)self.countdown];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(colletionVisibleTimer:) userInfo:nil repeats:YES];

    
}

#pragma mark Support Methods
- (void)colletionVisibleTimer:(NSTimer*)timer
{
    self.countdown--;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02ld", 0, (unsigned long)self.countdown];
    if(self.countdown == 0)//turn all images
    {
        [self.gameTimer invalidate];
        self.playState = PlayStatePlaying;
        [self filpAllCards];
        [self updateQuestionView];

    }
}

- (void)resetGame
{
    self.isAllImagesLoaded = NO;
    self.timerLabel.text = @"";
}

- (void)hideOrShowStartGameButton:(BOOL)hide
{
    self.startGameButton.hidden = hide;
    self.startGameButton.userInteractionEnabled = !hide;
    hide ? [self.view sendSubviewToBack:self.startGameButton] :  [self.view bringSubviewToFront:self.startGameButton];
   
}

- (void)filpAllCards
{
    [self.memoryGameCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        MemoryCardCell *cardCell = (MemoryCardCell*)obj;
        [cardCell flipImage];
    }];
    
}
- (void) updateQuestionView
{
    FlickrInfo *info = [self.modelInfoArray objectAtIndex:self.randomIndex];
    self.questionView.imageURL = [NSURL URLWithString:info.imageUrl];
    self.questionView.alpha = 0.0;
    self.timerLabel.hidden = YES;
    [UIView animateWithDuration:1 animations:^{
        self.questionView.alpha = 1.0;
    } completion:nil];

}

@end
