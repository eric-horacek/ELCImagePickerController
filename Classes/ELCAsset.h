//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol ELCAssetProtocol;
@class ALAsset;

typedef void (^ELCAssetDidSelectAssetBlock)(ALAsset *asset);

@interface ELCAsset : UIView {
	ALAsset *asset;
	UIImageView *overlayView;
	BOOL selected;
	id parent;
	ELCAssetDidSelectAssetBlock didSelectAssetBlock;
}

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) id<ELCAssetProtocol> delegate;
@property (nonatomic, copy) ELCAssetDidSelectAssetBlock didSelectAssetBlock;

-(id)initWithAsset:(ALAsset*)_asset;
-(BOOL)selected;

@end

@protocol ELCAssetProtocol <NSObject>

@optional
- (void)assetSelected:(ELCAsset*)asset;

@end