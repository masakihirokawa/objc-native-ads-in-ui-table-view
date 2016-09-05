//
//  ViewController.m
//  NativeAdsInUITableView
//
//  Created by Dolice on 2016/09/05.
//  Copyright © 2016 Dolice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property UITableView *sampleList; // サンプルリスト

@end

@implementation ViewController

CGFloat    const CELL_HEIGHT     = 80;  // セルの縦幅
NSUInteger const CELL_NUM        = 24;  // セルの総数

int        const NATIVE_ADS_PER  = 8;   // ネイティブ広告をリスト何件毎に表示するか
int        const NATIVE_ADS_NUM  = 2;   // ネイティブ広告を最大何個表示するか
BOOL       const SHOW_NATIVE_ADS = YES; // ネイティブ広告を表示するか

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // サンプルリスト配置
    [self setSampleList];
}

#pragma mark - Sample List

// サンプルリスト配置
- (void)setSampleList
{
    CGFloat const sampleListWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat const sampleListHeight = [[UIScreen mainScreen] bounds].size.height;
    _sampleList = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, sampleListWidth, sampleListHeight)
                                               style:UITableViewStylePlain];
    _sampleList.delegate        = self;
    _sampleList.dataSource      = self;
    _sampleList.backgroundColor = [UIColor whiteColor];
    _sampleList.separatorStyle  = UITableViewCellSeparatorStyleNone;
    
    [_sampleList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_sampleList];
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // インデックス値の保持
    NSUInteger const index = [indexPath indexAtPosition:[indexPath length] - 1];
    
    // セルの識別子定義
    NSString *const CellIdentifier = [NSString stringWithFormat:@"Cell%lu", (unsigned long)index];
    NSString *const NativeAdsCellIdentifier = [NSString stringWithFormat:@"NativeAds%lu", (unsigned long)index];
    
    // ネイティブ広告を表示する位置であるか取得し、セルの識別子を渡す
    UITableViewCell *cell;
    BOOL const isNativeAdsPosition = [self showNativeAdsByIndexId:index];
    if (isNativeAdsPosition) {
        cell = [tableView dequeueReusableCellWithIdentifier:NativeAdsCellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    if (cell == nil) {
        // サンプルラベルの座標と寸法定義
        CGFloat const labelX      = 18;
        CGFloat const labelWidth  = [[UIScreen mainScreen] bounds].size.width - labelX;
        CGFloat const labelHeight = CELL_HEIGHT;
        
        // ネイティブ広告を表示する位置であるか判定
        if (isNativeAdsPosition) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NativeAdsCellIdentifier];
            
            // TODO: ネイティブ広告表示
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0.0, labelWidth, labelHeight)];
            label.text = @"NativeAds";
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 0;
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            // TODO: 通常のセル表示
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0.0, labelWidth, labelHeight)];
            label.text = [NSString stringWithFormat:@"List - %lu", [self correctedIndexId:index]];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 0;
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
        }
    }
    
    return cell;
}

// セルタップ時のイベント
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // インデックス値の保持
    NSUInteger const index = [indexPath indexAtPosition:[indexPath length] - 1];
    
    // TODO: ネイティブ広告を表示した分だけインデックス値に誤差が生じるため、通常はこの値を使用して処理を行う
    NSUInteger const corretedIndexId = [self correctedIndexId:index];
    NSLog(@"%lu", corretedIndexId);
    
    // ネイティブ広告を表示する位置であるか取得し、タップ時の処理を分ける
    BOOL const isNativeAdsPosition = [self showNativeAdsByIndexId:index];
    if (isNativeAdsPosition) {
        // TODO: ネイティブ広告セルの場合の処理
        
    } else {
        // TODO: 通常セルの場合の処理
        
    }
}

// セルの総数を指定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger const cellNum = [self cellNum];
    
    return cellNum + [self nativeAdsNumPerScreen:cellNum];
}

// セルの総数を返す
- (NSUInteger)cellNum
{
    return CELL_NUM;
}

// セルのセクション数を設定
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// セル高さを設定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

// セルの背景色指定
- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Native Ads

// ネイティブ広告を表示するインデックス位置であるか取得
- (BOOL)showNativeAdsByIndexId:(NSUInteger)indexId
{
    if (!SHOW_NATIVE_ADS) {
        return NO;
    }
    
    NSUInteger const positionId = (indexId + 1);
    int const maxDisplayPositionId = NATIVE_ADS_NUM * NATIVE_ADS_PER;
    if (positionId > maxDisplayPositionId) {
        return NO;
    }
    
    return positionId % NATIVE_ADS_PER == 0;
}

// ネイティブ広告の表示分を補正したインデックス値の取得
- (NSUInteger)correctedIndexId:(NSUInteger)indexId
{
    return indexId - [self nativeAdsCorrectionValue:indexId];
}

// ネイティブ広告の表示によって生じるインデックス補正値を取得
- (int)nativeAdsCorrectionValue:(NSUInteger)indexId
{
    if (!SHOW_NATIVE_ADS) {
        return 0;
    }
    
    NSUInteger const positionId = (indexId + 1);
    for (int i = NATIVE_ADS_NUM; i > 0; i--) {
        if (positionId > (i * NATIVE_ADS_PER)) {
            return i;
        }
    }
    
    return 0;
}

// 画面に表示するネイティブ広告の数を取得
- (int)nativeAdsNumPerScreen:(NSUInteger)comparisonNum
{
    if (!SHOW_NATIVE_ADS) {
        return 0;
    }
    
    int const maxDisplayPositionId = NATIVE_ADS_PER * NATIVE_ADS_NUM;
    if (comparisonNum >= maxDisplayPositionId) {
        return NATIVE_ADS_NUM;
    }
    
    return roundf(comparisonNum / NATIVE_ADS_PER);
}

@end
