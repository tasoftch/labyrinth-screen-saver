//
//  LabyView.m
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 10.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import "LabyView.h"


@implementation LabyView
@synthesize labyEntries, sizeType, editMode, useBeep;

- (void)dealloc
{
    self.labyEntries = nil;
	[self removeObserver:self forKeyPath:@"sizeType"];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeType = 16;
		self.editMode = 1;
		self.useBeep = YES;
		
		startPoint = OrderOutPoint;
		targetPoint = OrderOutPoint;
		marker = OrderOutPoint;
		
		[self selectAllAsImpermeable:YES];
		
		[self addObserver:self forKeyPath:@"sizeType" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSInteger lines = sizeType;
	
	
	
	double width = self.frame.size.width;

	double space = width / lines;
	
	
	
	NSBezierPath *imp = [NSBezierPath bezierPath];
	NSBezierPath *norm = [NSBezierPath bezierPath];
	NSBezierPath *start = [NSBezierPath bezierPath];
	NSBezierPath *end = [NSBezierPath bezierPath];
	
	
	[[NSColor blackColor] set];
	NSRectFill(dirtyRect);
	
	
	NSInteger maxXCount = lines+1;
	NSInteger maxYCount = lines+1;
	
	NSInteger startX = 0;
	NSInteger startY = 0;
	
	
	/*
	if(dirtyRect.origin.x != 0 && dirtyRect.origin.y != 0) {
		startX = floor(dirtyRect.origin.x / space)-1;
		startY = floor(dirtyRect.origin.y / space) -1;
		
		maxXCount = startX+5;
		maxYCount = startY+5;
	}
	*/
	
	for(NSInteger x=startX;x < maxXCount;x++) {
		for(NSInteger y = startY;y < maxYCount;y++) {
			NSPoint s = NSMakePoint(y*space, x*space);
			NSPoint eh = NSMakePoint(y*space+space, x*space);
			NSPoint ev = NSMakePoint(y*space, x*space+space);
			
			if(startPoint.x == y && startPoint.y == x) {
				[start moveToPoint:s];
				if(y == 0 || y == lines)
					[start lineToPoint:ev];
				else
					[start lineToPoint:eh];
			}
			
			if(targetPoint.x == y && targetPoint.y == x) {
				[end moveToPoint:s];
				if(y == 0 || y == lines)
					[end lineToPoint:ev];
				else
					[end lineToPoint:eh];
			}
			
			if(impH[x][y]) {
				[imp moveToPoint:s];
				[imp lineToPoint:eh];
			}
			else {
				[norm moveToPoint:s];
				[norm lineToPoint:eh];
			}
			
			if(impV[x][y]) {
				[imp moveToPoint:s];
				[imp lineToPoint:ev];
			}
			else {
				[norm moveToPoint:s];
				[norm lineToPoint:ev];
			}
		}
	}

	[norm setLineWidth:3.0];
	[imp setLineWidth:3.0];
	[start setLineCapStyle:NSRoundLineCapStyle];
	[start setLineWidth:20.0];
	[end setLineCapStyle:NSRoundLineCapStyle];
	[end setLineWidth:20.0];
	
	
	
	[norm setLineCapStyle:NSRoundLineCapStyle];
	[imp setLineCapStyle:NSRoundLineCapStyle];
	
	[[NSColor colorWithCalibratedRed:.1 green:.1 blue:.1 alpha:1.0] set];
	[norm stroke];
	
	[[NSColor whiteColor] set];
	[imp stroke];
	
	[[NSColor redColor] set];
	[start stroke];
	
	[[NSColor blueColor] set];
	[end stroke];
	
	// Draw Pointer
	
	
	if(MAX(marker.x, marker.y) < 0)
		return;
	
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSRect rect = NSMakeRect(0.0, 0.0, space, space);
	double oneP = rect.size.width * .1;
	
	rect.origin.x += oneP + marker.x * space;
	rect.origin.y += oneP + marker.y * space;
	
	rect.size.width -= oneP + oneP;
	rect.size.height -= oneP + oneP;
	[[NSBezierPath bezierPathWithRoundedRect:rect xRadius:rect.size.width * .3 yRadius:rect.size.width * .3] addClip];
	
	[[[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.0 green:.6 blue:.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:0.0 green:.4 blue:.0 alpha:1.0]] autorelease] drawInRect:rect angle:270.0f];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (BOOL)isRow:(NSInteger)row impermeableAtColumn:(NSInteger)column {
	if(MAX(row, column)>64)
		@throw [NSException exceptionWithName:@"TALabyMatrixOutOfRangeException" reason:@"The Column and/or the Row index are out of range!" userInfo:nil];
	
	if(impH[row][column])
		return YES;
	return NO;
}

- (BOOL)isColumn:(NSInteger)column impermeableAtRow:(NSInteger)row {
	if(MAX(row, column)>64)
		@throw [NSException exceptionWithName:@"TALabyMatrixOutOfRangeException" reason:@"The Column and/or the Row index are out of range!" userInfo:nil];
	
	if(impV[row][column])
		return YES;
	return NO;
}

- (void)didChange:(NSEvent *)theEvent {
	NSSound *snd = [NSSound soundNamed:@"Pop"];
	if(useBeep)
		[snd play];
	
	/*
	NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	double width = self.frame.size.width;
	
	NSInteger lines = sizeType;
	NSInteger space = width / lines;

	NSRect upd = NSMakeRect(pt.x-space, pt.y-space, space*2, space*2);
	
	[self setNeedsDisplayInRect:upd];
	*/
	
	[self setNeedsDisplay:YES];
	
	NSDocument *doc = [[NSDocumentController sharedDocumentController] documentForWindow:[self window]];
	
	[doc updateChangeCount:NSChangeDone];
}

- (void)selectAllAsImpermeable:(BOOL)flag {
	for(int x=0;x < 64;x++) {
		for(int y = 0;y < 64;y++) {
			impV[x][y] = flag;
			impH[x][y] = flag;
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	if(editMode != 2) {
		NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		
		double width = self.frame.size.width;
		
		NSInteger lines = sizeType;
		
		NSInteger space = width / lines;

		NSInteger xCut = (((NSInteger)pt.x) % space);
		
		BOOL flag = (editMode == 0) ? YES : NO;
		
		if(xCut < 10) {
			NSInteger column = pt.x / space;
			NSInteger row = floor(pt.y / space);
			
			if(editMode < 2) {
				if(column < 1 || column > (lines - 1) || row > lines-1)
					return;
				if(impV[row][column] != flag) {
					impV[row][column] = flag;
					[self didChange:theEvent];
				}
			}
			
			if(editMode == 3 && (column == 0 || column == lines)) {
				if(startPoint.x != column || startPoint.y != row) {
					startPoint.x = column;
					startPoint.y = row;
					[self didChange:theEvent];
				}
			}
			
			if(editMode == 4 && (column == 0 || column == lines)) {
				if(targetPoint.x != column || targetPoint.y != row) {
					targetPoint.x = column;
					targetPoint.y = row;
					[self didChange:theEvent];
				}
			}
		}
		
		NSInteger yCut = (((NSInteger)pt.y) % space);
		if(yCut < 10) {
			NSInteger row = pt.y / space;
			
			NSInteger column = floor(pt.x / space);
			
			if(editMode < 2) {
				if(row < 1 || row > (lines - 1) || column > lines-1)
					return;
				if(impH[row][column] != flag) {
					impH[row][column] = flag;
					[self didChange:theEvent];
				}
			}
			
			if(editMode == 3 && (row == 0 || row == lines)) {
				if(startPoint.x != column || startPoint.y != row) {
					startPoint.x = column;
					startPoint.y = row;
					[self didChange:theEvent];
				}
			}
			
			if(editMode == 4 && (row == 0 || row == lines)) {
				if(targetPoint.x != column || targetPoint.y != row) {
					targetPoint.x = column;
					targetPoint.y = row;
					[self didChange:theEvent];
				}
			}
		}
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	[self mouseDragged:theEvent];
}

- (IBAction)applyEdition:(id)sender {
	if(editMode == 1)
		[self selectAllAsImpermeable:YES];
	if(editMode == 0)
		[self selectAllAsImpermeable:NO];
	
	[self didChange:nil];
}

- (NSData *)dataRepresentation {
	NSMutableData *data = [NSMutableData data];
	NSArchiver *archiver = [[NSArchiver alloc] initForWritingWithMutableData:data];
	
	[archiver encodeObject:[NSNumber numberWithInteger:sizeType]];
	[archiver encodeObject:[NSNumber numberWithInteger:editMode]];
	[archiver encodeObject:[NSNumber numberWithBool:useBeep]],
	
	[archiver encodePoint:startPoint];
	[archiver encodePoint:targetPoint];
	
	
	NSPoint ptsH[4096];
	NSUInteger countH = 0;
	NSPoint ptsV[4096];
	NSUInteger countV = 0;
	
	for(int x=0;x < 64;x++) {
		for(int y=0;y < 64;y++) {
			if(impH[x][y])
				ptsH[countH++] = NSMakePoint(x, y);

			if(impV[x][y])
				ptsV[countV++] = NSMakePoint(x, y);
		}
	}
	
	[archiver encodePoint:NSMakePoint(countH, countV)];
	
	for(int e=0;e < countH;e++)
		[archiver encodePoint:ptsH[e]];
	
	for(int e=0;e < countV;e++)
		[archiver encodePoint:ptsV[e]];
	
	[archiver release];
	return data;
}

- (BOOL)reloadWithDataRepresentation:(NSData *)data {
	NSUnarchiver *unarchiver = [[NSUnarchiver alloc] initForReadingWithData:data];
	
	self.sizeType = [[unarchiver decodeObject] integerValue];
	self.editMode = [[unarchiver decodeObject] integerValue];
	self.useBeep = [[unarchiver decodeObject] boolValue];
	
	startPoint = [unarchiver decodePoint];
	targetPoint = [unarchiver decodePoint];
	
	NSUInteger countH, countV;
	NSPoint p = [unarchiver decodePoint];
	
	countH = p.x;
	countV = p.y;
	
	[self selectAllAsImpermeable:NO];
	
	for(int e=0;e < countH;e++) {
		NSPoint pt = [unarchiver decodePoint];
		impH[(NSInteger)pt.x][(NSInteger)pt.y] = YES;
	}
	
	for(int e=0;e < countV;e++) {
		NSPoint pt = [unarchiver decodePoint];
		impV[(NSInteger)pt.x][(NSInteger)pt.y] = YES;
	}
	
	return YES;
}
@end
