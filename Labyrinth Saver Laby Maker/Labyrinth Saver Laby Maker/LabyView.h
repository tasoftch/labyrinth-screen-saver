//
//  LabyView.h
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 10.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define OrderOutPoint NSMakePoint(-1,-1)

@interface LabyView : NSView {
	BOOL impH[64][64];
	BOOL impV[64][64];
	
	NSInteger sizeType;
	NSInteger editMode;
	
	BOOL useBeep;
	
	NSPoint startPoint;
	NSPoint targetPoint;
	
	@public
	NSPoint marker;
}

@property (copy) NSArray *labyEntries;
@property (assign) NSInteger sizeType, editMode;

@property (assign) BOOL useBeep;

- (BOOL)isRow:(NSInteger)row impermeableAtColumn:(NSInteger)column;
- (BOOL)isColumn:(NSInteger)column impermeableAtRow:(NSInteger)row;

- (void)selectAllAsImpermeable:(BOOL)flag;

- (IBAction)applyEdition:(id)sender;

- (NSData *)dataRepresentation;
- (BOOL)reloadWithDataRepresentation:(NSData *)data;
@end
