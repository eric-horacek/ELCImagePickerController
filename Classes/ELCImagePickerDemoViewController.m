//
//  ELCImagePickerDemoViewController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerDemoViewController.h"
#import "ELCAlbumPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ELCImagePickerDemoViewController ()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollview;

-(IBAction)launchController;

@end

@implementation ELCImagePickerDemoViewController

@synthesize scrollview = _scrollview;

-(IBAction)launchController {
		
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
	albumController.multiSelection = YES;
	
	__block ELCImagePickerDemoViewController *safeSelf = self;
	__block UIScrollView *safeScrollView = _scrollview;
	
	[albumController setDidFinishPickMedia:^(NSArray *info) {		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			CGRect workingFrame = safeScrollView.frame;
			workingFrame.origin.x = 0;
			
			for (NSDictionary *dict in info)
			{
				__block UIImageView *imageview = [[UIImageView alloc] initWithImage:[dict objectForKey:UIImagePickerControllerOriginalImage]];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[imageview setContentMode:UIViewContentModeScaleAspectFit];
					imageview.frame = workingFrame;
					[safeScrollView addSubview:imageview];
					[imageview release];
				});
				
				workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[safeScrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];			
				[safeSelf dismissModalViewControllerAnimated:YES];
			});
		});
	}];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumController];
    
	[self presentModalViewController:navigationController animated:YES];
	
    [albumController release];
	[navigationController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

#pragma mark - Memory Management

- (void)dealloc
{
	[_scrollview release];
	
	[super dealloc];
}

@end