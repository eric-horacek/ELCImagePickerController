//
//  AssetCell.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAsset.h"

@interface ELCAssetCell : UITableViewCell
{
	NSArray *rowAssets;
	ELCAssetDidSelectAssetBlock didSelectAssetBlock;
}

-(id)initWithAssets:(NSArray*)_assets reuseIdentifier:(NSString*)_identifier;
-(void)setAssets:(NSArray*)_assets;

+ (CGFloat)cellPadding;

@property (nonatomic,retain) NSArray *rowAssets;
@property (nonatomic, copy) ELCAssetDidSelectAssetBlock didSelectAssetBlock;

@end
