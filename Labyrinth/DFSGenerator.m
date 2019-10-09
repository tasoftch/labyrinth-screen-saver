//
//  DFSGenerator.m
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 12.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import "DFSGenerator.h"
#import "LabyrinthView.h"

PTS MAKE_PTS(int x, int y) {
	PTS pts;
	pts.row=y;pts.col=x;
	return pts;
}

@interface LabyrinthView (GEN)

- (void)setImpermeableOption:(NSInteger)opt forField:(PTS)pts;
- (NSInteger)impermeableOptionForField:(PTS)pts;
@end

@implementation LabyrinthView ( GEN )
- (void)setImpermeableOption:(NSInteger)opt forField:(PTS)pts {
	impermeables[pts.row][pts.col] = opt;
}

- (NSInteger)impermeableOptionForField:(PTS)pts {
	return impermeables[pts.row][pts.col];
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
	p.col = pt.x;
	p.row = pt.y;
	
	visited[vCount++] = p;
	matrix[p.row][p.col] = YES;
}

- (void)addXPoint:(PTS)pts {
	[self addPoint:NSMakePoint(pts.col, pts.row)];
}

- (PTS)randomNextPoint:(NSSize)maxFields direction:(int*)dir {
	PTS current = visited[vCount-1];

	BOOL toLeft, toTop, toRight, toBottom;
	toBottom = toLeft = toTop = toRight = YES;
	int poss = 4;
	
	if(current.col<1 || matrix[current.row][current.col-1]) {
		toLeft = NO;
		poss--;
	}
	
	if(current.row<1 || matrix[current.row-1][current.col]) {
		toBottom = NO;
		poss--;
	}
	
	if(current.col+1>=maxFields.width || matrix[current.row][current.col+1]) {
		toRight = NO;
		poss--;
	}
	
	if(current.row+1>=maxFields.height || matrix[current.row+1][current.col]) {
		toTop = NO;
		poss--;
	}

	if(poss == 1) {
		
		if(toLeft) {
			if(dir) *dir = 1;
			return MAKE_PTS(current.col-1, current.row);
		}
		if(toTop) {
			if(dir) *dir = 2;
			return MAKE_PTS(current.col, current.row+1);
		}
		if(toRight) {
			if(dir) *dir = 3;
			return MAKE_PTS(current.col+1, current.row);
		}
		if(toBottom) {
			if(dir) *dir = 4;
			return MAKE_PTS(current.col, current.row-1);
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
		
		if(_dir==1) return MAKE_PTS(current.col-1, current.row);
		if(_dir==2) return MAKE_PTS(current.col, current.row+1);
		if(_dir==3) return MAKE_PTS(current.col+1, current.row);
		if(_dir==4) return MAKE_PTS(current.col, current.row-1);
	}
	if(dir) *dir = 0;
	return MAKE_PTS(-1, -1);
}


- (void)generateInView:(LabyrinthView *)view {
	vCount = 0;
	
	
	srand((unsigned int)time(NULL));
	
	view->startPoint.col = 0;
	view->startPoint.row = rand() % view->rowCount;
	
	view->endPoint.col = (int)view->colCount-1;
	view->endPoint.row = rand() % view->rowCount;
	
	view->isGenerating = YES;
	
	for(int x=0;x < 128;x++) {
		for(int y=0;y<128;y++) {
			[view setImpermeableOption:TABottomImpermeable | TARightImpermeable forField:MAKE_PTS(x, y)];
			view->visited[y][x] = NO;
			matrix[y][x] = NO;
		}
	}

	vCount = 0;
	
	[self addXPoint:view->startPoint];
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		while ( YES ) {
			int dir=0;
			__block PTS nextPoint = [self randomNextPoint:NSMakeSize(view->colCount, view->rowCount) direction:&dir];
			
			if(nextPoint.col != -1) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					if(dir == 1) {
						NSInteger imp = [view impermeableOptionForField:nextPoint];
						[view setImpermeableOption:imp &~ TARightImpermeable forField:nextPoint];
					}
					if(dir == 2) {
						NSInteger imp = [view impermeableOptionForField:nextPoint];
						[view setImpermeableOption:imp &~ TABottomImpermeable forField:nextPoint];
					}
					if(dir == 3) {
						NSInteger imp = [view impermeableOptionForField:nextPoint];
						PTS pts = nextPoint;
						pts.col--;
						
						NSInteger _imp = [view impermeableOptionForField:pts];
						
						[view setImpermeableOption:(_imp != 3) ? 0 : imp &~ TARightImpermeable forField:pts];
					}
					if(dir == 4) {
						NSInteger imp = [view impermeableOptionForField:nextPoint];
						PTS pts = nextPoint;
						pts.row++;
						NSInteger _imp = [view impermeableOptionForField:pts];
						
						[view setImpermeableOption:(_imp != 3) ? 0 : imp &~ TABottomImpermeable forField:pts];
					}
				});
				
				[self addXPoint:nextPoint];
			}
			else {
				if(vCount > 1) {
					vCount--;
					continue;
				}
				dispatch_sync(dispatch_get_main_queue(), ^{
					view->isGenerating = NO;
					[view didFinish];
				});
				break;
			}
		}
	});
}
@end
