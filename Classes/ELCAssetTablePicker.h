//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ELCAssetTablePickerDidFinishSelectingAssetsBlock)(NSArray *assets);

@interface ELCAssetTablePicker : UITableViewController

@property (nonatomic, assign, getter = isMultiSelection) BOOL multiSelection;
@property (nonatomic, retain) ALAssetsGroup *assetsGroup;
@property (nonatomic, copy) ELCAssetTablePickerDidFinishSelectingAssetsBlock didFinishSelectingAssets; 

@end