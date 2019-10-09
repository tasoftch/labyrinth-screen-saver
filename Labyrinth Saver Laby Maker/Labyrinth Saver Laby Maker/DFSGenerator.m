//
//  DFSGenerator.m
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 12.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import "DFSGenerator.h"

PTS MAKE_PTS(int x, int y) {
	PTS pts;
	pts.x=x;pts.y=y;
	return pts;
}

@interface LabyView (GEN)
- (NSPoint)startPoint;
@end

@implementation LabyView ( GEN )
- (NSPoint)startPoint {
	return startPoint;
}
@end


@implementation DFSGenerator

- (void)clearStack {
	for(int x=0;x<48;x++) {
		for(int y=0;y < 48;y++)
			matrix[x][y] = NO;
	}
}

- (void)addPoint:(NSPoint)pt {
	PTS p;
	p.x = pt.x;
	p.y = pt.y;
	
	visited[vCount++] = p;
	matrix[p.x][p.y] = YES;
}

- (void)addXPoint:(PTS)pts {
	[self addPoint:NSMakePoint(pts.x, pts.y)];
}

- (PTS)randomNextPoint:(NSInteger)maxFields direction:(int*)dir {
	PTS current = visited[vCount-1];
	
	BOOL toLeft, toTop, toRight, toBottom;
	toBottom = toLeft = toTop = toRight = YES;
	int poss = 4;
	
	if(current.x<1 || matrix[current.x-1][current.y]) {
		toLeft = NO;
		poss--;
	}
	
	if(current.y<1 || matrix[current.x][current.y-1]) {
		toBottom = NO;
		poss--;
	}
	
	if(current.x+1>=maxFields || matrix[current.x+1][current.y]) {
		toRight = NO;
		poss--;
	}
	
	if(current.y+1>=maxFields || matrix[current.x][current.y+1]) {
		toTop = NO;
		poss--;
	}
	
	if(poss == 1) {
		if(toLeft) {
			if(dir) *dir = 1;
			return MAKE_PTS(current.x-1, current.y);
		}
		if(toTop) {
			if(dir) *dir = 2;
			return MAKE_PTS(current.x, current.y+1);
		}
		if(toRight) {
			if(dir) *dir = 3;
			return MAKE_PTS(current.x+1, current.y);
		}
		if(toBottom) {
			if(dir) *dir = 4;
			return MAKE_PTS(current.x, current.y-1);
		}
	}
	
	
	if(poss > 1) {
		int ps = rand() % poss;
		int p[4];
		int c=0;
		if(toLeft) p[c++] = 1;
		if(toTop) p[c++] = 2;
		if(toRight) p[c++] = 3;
		if(toBottom) p[c++] = 4;
		
		int _dir = p[ps];
		
		if(dir) *dir = _dir;
		
		if(_dir==1) return MAKE_PTS(current.x-1, current.y);
		if(_dir==2) return MAKE_PTS(current.x, current.y+1);
		if(_dir==3) return MAKE_PTS(current.x+1, current.y);
		if(_dir==4) return MAKE_PTS(current.x, current.y-1);
	}
	if(dir) *dir = 0;
	return MAKE_PTS(-1, -1);
}

- (void)generateInView:(LabyView *)view withOptions:(NSUInteger)options {
	NSPoint start = [view startPoint];
	
	srand((unsigned int)time(NULL));
	
	view->marker = start;
	[view selectAllAsImpermeable:YES];
	
	if(options == 1)
		[view setNeedsDisplay:YES];
	
	vCount = 0;
	
	[self addPoint:start];
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		while ( main.isGenerating ) {
			int dir=0;
			PTS nextPoint = [self randomNextPoint:view.sizeType direction:&dir];
			
			if(nextPoint.x != -1) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					if(dir == 1) {
						[view removeWallAtPosition:NSMakePoint(nextPoint.x+1, nextPoint.y) horizontally:NO];
					}
					if(dir == 2) {
						[view removeWallAtPosition:NSMakePoint(nextPoint.x, nextPoint.y) horizontally:YES];
					}
					if(dir == 3) {
						[view removeWallAtPosition:NSMakePoint(nextPoint.x, nextPoint.y) horizontally:NO];
					}
					if(dir == 4) {
						[view removeWallAtPosition:NSMakePoint(nextPoint.x, nextPoint.y+1) horizontally:YES];
					}
					
					
					if(options == 1) {
						view->marker = NSMakePoint(nextPoint.x, nextPoint.y);
						[view didChange:nil];
					}
				});
				
				[self addXPoint:nextPoint];
			}
			else {
				if(vCount > 1) {
					vCount--;
					continue;
				}
				[main didFinish];
				break;
			}
			
			if(options==1)
				[NSThread sleepForTimeInterval:0.15];
		}
		
		if(options == 0)
			[view didChange:nil];
	});
}
@end
