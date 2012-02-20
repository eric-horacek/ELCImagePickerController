//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class ELCAsset;
@class ALAsset;

typedef void (^ELCAssetDidSelectAssetBlock)(ALAsset *asset);

@interface ELCAsset : UIView 

@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, copy) ELCAssetDidSelectAssetBlock didSelectAssetBlock;
@property (nonatomic, readonly) UIImageView *imageView;

@end