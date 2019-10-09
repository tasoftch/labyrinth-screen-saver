//
//  DFSGenerator.h
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 12.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MazeGenerator.h"
#import "LabyView.h"

typedef struct {
	int x;
	int y;
} PTS;

@interface DFSGenerator : NSObject {
	BOOL matrix[48][48];
	PTS visited[2304];
	NSInteger vCount;
@public
	MazeGenerator *main;
}


- (void)generateInView:(LabyView *)view withOptions:(NSUInteger)options;
@end
