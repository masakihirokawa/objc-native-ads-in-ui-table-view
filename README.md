iOSアプリのテーブルビューにネイティブ広告を表示するサンプル
============================

##サンプルの解説

###1. ネイティブ広告の表示頻度と最大表示数を定義

まずネイティブ広告をリスト何件毎に表示するかと、画面に最大何個まで表示するかを定義しています。

下記の例では、リスト8件毎にネイティブ広告を表示し、画面に最大2個まで表示するよう指定しています。

```objective-c
int const NATIVE_ADS_PER  = 8; // ネイティブ広告をリスト何件毎に表示するか
int const NATIVE_ADS_NUM  = 2; // ネイティブ広告を最大何個表示するか
```

###2. ネイティブ広告の表示数によってセルの総数を補正

ネイティブ広告を表示する分だけセルの総数も補正しなければならないので、まず下記の「_nativeAdsNumPerScreen_」メソッドから画面に表示するネイティブ広告の総数を取得します。

```objective-c
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
```

そして本来のセルの総数にネイティブ広告の数を加え、テーブルビューのセル総数を定義しています。

```objective-c
// セルの総数を指定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CELL_NUM + [self nativeAdsNumPerScreen:CELL_NUM];
}
```

###3. ネイティブ広告を表示するセルの識別子を通常のセルと分けて定義

セルの識別子は通常のセルとネイティブ広告とで分ける必要があります。

まず、下記の「_showNativeAdsByIndexId_」メソッドにセルのインデックス値を渡し、ネイティブ広告を表示するインデックス位置であるか取得します。

```objective-c
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
```

次に、ネイティブ広告を表示する位置である場合と通常のセルの場合とでセルの識別子を分けます。

```objective-c
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
```

###4. ネイティブ広告のセルと通常のセルとで描画処理を分ける

ネイティブ広告を表示するセルであれば広告を表示し、通常のセルであれば通常のセル内容を表示するよう処理を分けます。

```objective-c
if (cell == nil) {
    // ネイティブ広告を表示する位置であるか判定
    if (isNativeAdsPosition) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NativeAdsCellIdentifier];
            
        // TODO: ネイティブ広告表示

    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        // TODO: 通常のセル表示

    }
}
```

ここでセルのインデックス値を取得して処理を行う際、そのままの値を使用すると正しく処理できませんので、下記の「_correctedIndexId_」メソッドに本来のインデックス値を渡し、ネイティブ広告の表示によって生じるインデックス値を補正して受け取る必要があります。

```objective-c
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
```

ネイティブ広告を表示した分だけインデックス値に誤差が生じるため、通常は下記のようにインデックス値を補正して処理を行います。

```objective-c
NSUInteger const corretedIndexId = [self nativeAdsCorrectionValue:index];
```

###5. セルタップ時のイベントを分ける

セルをタップした時のイベントも下記のように分けます。下記の例では、ネイティブ広告の背景がタップされると選択を解除するよう指定しています。

```objective-c
// セルタップ時のイベント
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // インデックス値の保持
    NSUInteger const index = [indexPath indexAtPosition:[indexPath length] - 1];
    
    // TODO: ネイティブ広告を表示した分だけインデックス値に誤差が生じるため、通常はこの値を使用して処理を行う
    NSUInteger const corretedIndexId = [self correctedIndexId:index];
    
    // ネイティブ広告を表示する位置であるか取得し、タップ時の処理を分ける
    BOOL const isNativeAdsPosition = [self showNativeAdsByIndexId:index];
    if (isNativeAdsPosition) {
        // TODO: ネイティブ広告セルの場合の処理
        
        // ネイティブ広告の背景はタップ禁止のため、セルの選択を解除する必要がある
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // デバッグ出力
        NSLog(@"NativeAds");
    } else {
        // TODO: 通常セルの場合の処理
        
        // デバッグ出力
        NSLog(@"corretedIndexId: %lu", corretedIndexId);
    }
}
```
