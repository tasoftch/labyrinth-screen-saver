//
//  Document.h
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 10.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LabyView.h"

@interface Document : NSDocument <NSWindowDelegate> {
	IBOutlet LabyView *labyView;
	IBOutlet NSDrawer *drawer;
	
	NSData *stackData;
}

@end
