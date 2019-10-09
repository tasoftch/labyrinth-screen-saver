//
//  DFSGenerator.h
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 12.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	int col;
	int row;
} PTS;

PTS MAKE_PTS(int x, int y);

@class LabyrinthView;

@interface DFSGenerator : NSObject {
	BOOL matrix[128][128];
	PTS visited[16384];
	NSInteger vCount;
}


- (void)generateInView:(LabyrinthView *)view;
@end
