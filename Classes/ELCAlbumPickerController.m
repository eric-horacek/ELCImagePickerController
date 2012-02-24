//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "UIImage+ScaleAndRotate.h"

@interface ELCAlbumPickerController ()

- (void)cancel:(id)sender;
- (void)makeMediaInfoWithAssets:(NSArray *)assets;

@end

@implementation ELCAlbumPickerController

@synthesize multiSelection = _multiSelection;
@synthesize assetGroups = _assetGroups;
@synthesize didFinishPickMedia = _didFinishPickMedia;

#pragma mark -
#pragma mark View lifecycle

static int compareGroupsUsingSelector(id p1, id p2, void *context)
{
    id value1 = [p1 valueForProperty:ALAssetsGroupPropertyType];
    id value2 = [p2 valueForProperty:ALAssetsGroupPropertyType];
    
    return [value2 compare:value1];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self setTitle:NSLocalizedString(@"AlbumsKey", NULL)];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        self.wantsFullScreenLayout = YES;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];

	_assetGroups = [[NSMutableArray alloc] init];
	
	__block NSMutableArray *safeAssetGroups = _assetGroups;
	__block ELCAlbumPickerController *safeSelf = self;

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];        
    [library enumerateGroupsWithTypes:ALAssetsGroupAll 
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if (group == nil) return;
                               
                               [safeAssetGroups addObject:group];
                               [safeAssetGroups sortUsingFunction:compareGroupsUsingSelector context:nil];

                               [safeSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                           }
                         failureBlock:^(NSError *error) {
                             
                             NSString *errorMessage;
                             NSString *errorTitle;
                             
                             // If we encounter a location services error, prompt the user to enable location services
                             if ([error code] == ALAssetsLibraryAccessUserDeniedError)
							 {
                                 errorMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"UserDeniedKey", NULL),[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
                                 errorTitle = [NSString stringWithString:NSLocalizedString(@"TitleKey", NULL)];
                             }
							 else if ([error code] == ALAssetsLibraryAccessGloballyDeniedError)
							 {
                                 errorMessage = [NSString stringWithString:NSLocalizedString(@"GloballyDeniedKey", NULL)]; 
                                 errorTitle = [NSString stringWithString:NSLocalizedString(@"TitleKey", NULL)];
                             }
							 else
							 {
                                 errorMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"AlbumErrorKey", NULL), [error localizedDescription]];
                                 errorTitle = [NSString stringWithString:NSLocalizedString(@"ErrorKey", NULL)];
                             }
                             
                             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                              message:errorMessage
                                                                             delegate:nil 
                                                                    cancelButtonTitle:NSLocalizedString(@"OkKey", NULL) 
                                                                    otherButtonTitles:nil];
                             [alert show];
                             [alert release];                                   
                         }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

#pragma mark - Private Methods

- (void)makeMediaInfoWithAssets:(NSArray *)assets;
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSMutableArray *returnArray = [[NSMutableArray alloc] init];
		
		for(ALAsset *asset in assets)
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
			[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
			
			CGImageRef fullImageRef = [[asset defaultRepresentation] fullResolutionImage];
			UIImageOrientation orientation = ((UIImageOrientation)[[asset valueForProperty:@"ALAssetPropertyOrientation"] integerValue]);
			UIImage *fullResolutionImage = [UIImage imageWithCGImage:fullImageRef scale:1.0 orientation:orientation];
			
			UIImage *scaledImage = [fullResolutionImage scaledAndRotatedImageWithMaxResolution:1024];
			[workingDictionary setObject:scaledImage forKey:@"UIImagePickerControllerOriginalImage"];
			
			[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
			
			[returnArray addObject:workingDictionary];
			[workingDictionary release];
			
			[pool release];
		}
		
		__block NSArray *array = [[NSArray alloc] initWithArray:returnArray];
		[returnArray release];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_didFinishPickMedia(array);
			[array release];
		});
	});	
}

#pragma mark - Action Methods

- (void)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_assetGroups count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[_assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[g valueForProperty:ALAssetsGroupPropertyName]];
    cell.detailTextLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"PhotosCountKey", NULL), gCount];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)[_assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ELCAssetTablePicker *assetTablePicker = [[ELCAssetTablePicker alloc] init];
	assetTablePicker.multiSelection = _multiSelection;
	
	__block ELCAlbumPickerController *safeSelf = self;
		
	[assetTablePicker setDidFinishSelectingAssets:^(NSArray *assets) {
		if (safeSelf.didFinishPickMedia)
			[safeSelf makeMediaInfoWithAssets:assets];
	}];

    // Move me
    assetTablePicker.assetsGroup = [_assetGroups objectAtIndex:indexPath.row];
    [assetTablePicker.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
	[self.navigationController pushViewController:assetTablePicker animated:YES];
	
	[assetTablePicker release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 57;
}

#pragma mark - Memory management

- (void)dealloc 
{
	[_assetGroups release];
	[_didFinishPickMedia release];
    
    [super dealloc];
}

@end