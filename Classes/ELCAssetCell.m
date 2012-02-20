//
//  AssetCell.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"

@interface ELCAssetCell ()

@end

@implementation ELCAssetCell

@synthesize assets = _assets;
@synthesize didSelectAssetBlock = _didSelectAssetBlock;

- (void)setAssets:(NSArray *)assets
{		
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	[_assets release];
	_assets = [assets retain];
}

- (void)layoutSubviews
{
	CGFloat padding = [ELCAssetCell cellPadding];
    CGRect frame = CGRectMake(padding, padding / 2, self.bounds.size.width / 4 - 5, self.bounds.size.height - padding);
	
	for(ELCAsset *elcAsset in _assets) 
	{
		[elcAsset setFrame:frame];
		[elcAsset setDidSelectAssetBlock:_didSelectAssetBlock];
		[self addSubview:elcAsset];
		
		frame.origin.x = frame.origin.x + frame.size.width + padding;
	}
	
	[super layoutSubviews];
}

+ (CGFloat)cellPadding
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 13.0 : 4.0;
}

- (void)dealloc 
{
	[_assets release];
	[_didSelectAssetBlock release];
    
	[super dealloc];
}

@end
