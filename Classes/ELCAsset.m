//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

@interface ELCAsset ()

@property (nonatomic, retain) UIImageView *overlayView;

- (void)toggleSelection:(id)sender;

@end

@implementation ELCAsset

@synthesize asset = _asset;
@synthesize didSelectAssetBlock = _didSelectAssetBlock;
@synthesize overlayView = _overlayView;
@synthesize imageView = _imageView;

-(id)init
{	
	if (self = [super initWithFrame:CGRectMake(0, 0, 10, 10)]) 
	{				
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[_imageView setContentMode:UIViewContentModeScaleAspectFill];
		[_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_imageView setClipsToBounds:YES];
		[self addSubview:_imageView];
		
		_overlayView = [[UIImageView alloc] initWithFrame:self.bounds];
		[_overlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_overlayView setImage:[[UIImage imageNamed:@"Overlay.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
		[_overlayView setHidden:YES];
		[self addSubview:_overlayView];
		
		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelection:)];
		[self addGestureRecognizer:tapGestureRecognizer];
		[tapGestureRecognizer release];
    }
    
	return self;	
}

- (void)toggleSelection:(id)sender 
{   
	self.selected = !self.selected;
	
	if (_didSelectAssetBlock != NULL)
		_didSelectAssetBlock(_asset);
}

- (BOOL)isSelected 
{	
	return !_overlayView.hidden;
}

-(void)setSelected:(BOOL)selected 
{    
	[_overlayView setHidden:!selected];
}

- (void)dealloc 
{    	
    [_asset release];
	[_overlayView release];
	[_didSelectAssetBlock release];
	[_imageView release];
	
    [super dealloc];
}

@end

