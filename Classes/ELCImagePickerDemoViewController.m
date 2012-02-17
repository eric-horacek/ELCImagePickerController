//
//  ELCImagePickerDemoViewController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerDemoAppDelegate.h"
#import "ELCImagePickerDemoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ELCImagePickerDemoViewController

@synthesize scrollview;

-(IBAction)launchController {
		
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
	
	__block ELCImagePickerDemoViewController *safeSelf = self;
	
	[albumController setDidSelectAssetBlock:^(ALAsset *asset) {
		ALAssetRepresentation *representation = [asset defaultRepresentation];
		CGImageRef imageRef = [representation fullResolutionImage];
		if (imageRef != NULL)
		{
			UIImage *image = [UIImage imageWithCGImage:imageRef];
			
			UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
			
			CGSize size = [image size];
			float w = size.width , h = size.height;
			
			if (size.width < 44)
				w = 44;
			
			if (size.height < 44)
				h = 44;
			
			CGRect frame = CGRectMake(0, 0, w, h);
			
			[imageView setFrame:frame];
			
			[[safeSelf view] addSubview:imageView];
			
			[imageView release];
			
			[safeSelf dismissModalViewControllerAnimated:YES];
		}
	}];
	
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    
    ELCImagePickerDemoAppDelegate *app = (ELCImagePickerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.viewController presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [albumController release];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
	
	[self dismissModalViewControllerAnimated:YES];
	
	CGRect workingFrame = scrollview.frame;
	workingFrame.origin.x = 0;
	
	for(NSDictionary *dict in info) {
	
		UIImageView *imageview = [[UIImageView alloc] initWithImage:[dict objectForKey:UIImagePickerControllerOriginalImage]];
		[imageview setContentMode:UIViewContentModeScaleAspectFit];
		imageview.frame = workingFrame;
		
		[scrollview addSubview:imageview];
		[imageview release];
		
		workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
	}
	
	[scrollview setPagingEnabled:YES];
	[scrollview setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {

	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}


- (void)dealloc {
    [super dealloc];
}

@end
