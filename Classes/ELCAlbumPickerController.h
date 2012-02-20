//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ELCAlbumPickerControllerDidFinishPickingMediaWithInfoBlock)(NSArray *info);

@interface ELCAlbumPickerController : UITableViewController

@property (nonatomic, assign, getter = isMultiSelection) BOOL multiSelection;
@property (nonatomic, retain) NSMutableArray *assetGroups;
@property (nonatomic, copy) ELCAlbumPickerControllerDidFinishPickingMediaWithInfoBlock didFinishPickMedia;

@end