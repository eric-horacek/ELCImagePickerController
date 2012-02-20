//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ELCAssetTablePicker()

@property (nonatomic, retain) NSArray *assets;
@property (nonatomic, copy) ELCAssetDidSelectAssetBlock didSelectAssetBlock;

- (void)scrollTableViewToBottom;
- (NSInteger)assetsPerRow;
- (int)totalSelectedAssets;
- (void)doneAction:(id)sender;

@end

@implementation ELCAssetTablePicker

@synthesize multiSelection = _multiSelection;
@synthesize assetsGroup = _assetsGroup;
@synthesize assets = _assets;
@synthesize didFinishSelectingAssets = _didFinishSelectingAssets;
@synthesize didSelectAssetBlock = _didSelectAssetBlock;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];
	
	if (_multiSelection)
	{
		UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
		[self.navigationItem setRightBarButtonItem:doneButtonItem];
		[doneButtonItem release];
	}
    
	[self setTitle:@"Loading..."];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        self.wantsFullScreenLayout = YES;
	
	int count = [self.assetsGroup numberOfAssets];
	NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:count];
	ELCAsset *asset;
	for (int i = 0; i < count; i++)
	{
		asset = [[ELCAsset alloc] init];
		
		[assets addObject:asset];
		[asset release];
	}
	
	_assets = [[NSArray alloc] initWithArray:assets];
	[assets release];
    
	__block ELCAssetTablePicker *ss = self;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[ss.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
			if (result != nil)
			{
				__block ELCAsset *asset = [ss.assets objectAtIndex:ss.assets.count - index - 1];
				
				[asset setAsset:result];
			}
		}];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			ss.title = @"Select Photos";
			[self scrollTableViewToBottom];
		});
		
		for (ELCAsset *asset in ss.assets)
			dispatch_async(dispatch_get_main_queue(), ^{
				[asset.imageView setImage:[UIImage imageWithCGImage:[asset.asset thumbnail]]];
			});	
	});
	
	self.didSelectAssetBlock = ^(ALAsset *asset) {
		int totalSelectedAssets = [ss totalSelectedAssets];
		
		if (totalSelectedAssets == 0)
			ss.title = @"Select Photos";
		else if (totalSelectedAssets == 1)
			ss.title = @"1 Photo";
		else
			ss.title = [NSString stringWithFormat:@"%i Photos", totalSelectedAssets];
		
		if (totalSelectedAssets > 20) 
		{	
			ss.navigationItem.rightBarButtonItem.enabled = NO;
			
			if (SYSTEM_VERSION_LESS_THAN(@"5.0")) 
			{	
				if (ss.navigationItem.titleView == nil) 
				{	
					UILabel *titleLabel = [[UILabel alloc] init];
					
					CGRect frame = CGRectMake(0, 0, [ss.navigationItem.title sizeWithFont:[UIFont boldSystemFontOfSize:20.0]].width, 20.0);
					titleLabel.frame = frame;
					
					titleLabel.font = [UIFont boldSystemFontOfSize: 20.0f];
					titleLabel.textAlignment = ([ss.title length] < 10 ? UITextAlignmentCenter : UITextAlignmentLeft);
					
					titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
					titleLabel.backgroundColor = [UIColor clearColor];
					
					titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.35];
					titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
					
					titleLabel.text = ss.navigationItem.title;
					
					[ss.navigationItem setTitleView:titleLabel];
					[titleLabel release];
					
					ss.navigationItem.rightBarButtonItem.enabled = NO;
				}				
			} 
			else
			{
				UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
				UIColor *shadowColor = [UIColor colorWithWhite:0.0 alpha:0.35];
				
				NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor, UITextAttributeTextColor, shadowColor, UITextAttributeTextShadowColor, nil];
				
				[ss.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
			}
		} 
		else 
		{	
			ss.navigationItem.rightBarButtonItem.enabled = YES;
            
			if (SYSTEM_VERSION_LESS_THAN(@"5.0")) 
			{
				if (ss.navigationItem.titleView) 
					[ss.navigationItem setTitleView:nil];
			} 
			else 
			{
				UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
				UIColor *shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
				
				NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor, UITextAttributeTextColor, shadowColor, UITextAttributeTextShadowColor, nil];
				
				[ss.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
			}
		}
		
		if (!ss.multiSelection)
			if (ss.didFinishSelectingAssets != NULL)
				ss.didFinishSelectingAssets([NSArray arrayWithObject:asset]);
	};
}

- (void)scrollTableViewToBottom
{    
    int lastRowIndex = [self tableView:nil numberOfRowsInSection:0] - 1;
    if (lastRowIndex >= 0) 
	{
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];   
    }
}

- (void)doneAction:(id)sender
{
	NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
	    
	for(ELCAsset *asset in _assets) 
		if([asset isSelected])
			[selectedAssetsImages addObject:[asset asset]];
	
	if (_didFinishSelectingAssets != NULL)
		_didFinishSelectingAssets([NSArray arrayWithArray:selectedAssetsImages]);
	
    [selectedAssetsImages release];
}

- (NSInteger)assetsPerRow
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 6 : 4;
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ceil((float) [self.assetsGroup numberOfAssets] / (float) [self assetsPerRow]) + 2;
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)indexPath
{
	int index = (self.assetsGroup.numberOfAssets - 1) - (indexPath.row * [self assetsPerRow]);
    
    int minIndex;
	
    if (index < ([self assetsPerRow]-1))
        minIndex = 0;
    else
        minIndex = index-([self assetsPerRow]-1);
    
    if (index < _assets.count)
	{
		NSMutableArray *assetArray = [NSMutableArray array];
		
        for (NSInteger i = (index - minIndex); i > -1; i--)
            [assetArray addObject:[_assets objectAtIndex:minIndex + i]];
		
		return assetArray;
    }
    
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath row] == 0)
    {
        static NSString *whitespaceCellIdentifier = @"WhitespaceTableViewCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:whitespaceCellIdentifier];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:whitespaceCellIdentifier] autorelease];
        return cell;
    }
	
	if ([indexPath row] == [self tableView:tableView numberOfRowsInSection:[indexPath section]]-1)
	{
        static NSString *whitespaceCellIdentifier = @"ELCCountTableViewCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:whitespaceCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:whitespaceCellIdentifier] autorelease];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:19];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%i Photos", self.assetsGroup.numberOfAssets];
        
        return cell;
    }

	static NSString *CellIdentifier = @"Cell";
		
	ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	NSIndexPath *updatedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
	
	if (cell == nil) 
		cell = [[[ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	[cell setAssets:[self assetsForIndexPath:updatedIndexPath]];
	[cell setDidSelectAssetBlock:_didSelectAssetBlock];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (([indexPath row] == 0))
        return [ELCAssetCell cellPadding] / 2;
	
	if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)
        return 50;

	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 89.0 : 79.0;
}

- (int)totalSelectedAssets
{
    int count = 0;
    
    for(ELCAsset *asset in _assets) 
		if([asset isSelected]) 
            count++;	
    
    return count;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)dealloc 
{
    [_assets release];
	[_assetsGroup release];
	[_didSelectAssetBlock release];
	[_didFinishSelectingAssets release];
	
    [super dealloc];
}

@end
