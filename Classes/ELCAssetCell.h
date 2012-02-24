//
//  AssetCell.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAsset.h"

@interface ELCAssetCell : UITableViewCell

@property (nonatomic, copy) ELCAssetDidSelectAssetBlock didSelectAssetBlock;
@property (nonatomic, retain) NSArray *assets;

+ (CGFloat)cellPadding;

@end
