//
//  LabyrinthView.h
//  Labyrinth
//
//  Created by Thomas Abplanalp on 10.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "DFSGenerator.h"

typedef enum {
	TARightImpermeable = 1,
	TABottomImpermeable = 2
} TAImpermeable;

@interface NSColor (Integrable)
+ (id)colorWithInteger:(NSInteger)integer;
- (NSInteger)integerValue;
@end

typedef enum {
	TALeft = 1,
	TATop,
	TARight,
	TABottom
} TADirection;


typedef struct {
	PTS pts;
	TADirection dir;
} PTS_DIR;


@interface LabyrinthView : ScreenSaverView {
	NSInteger impermeables[128][128];

	NSColor *backgroundColor, *gridColor, *solutionColor;
	NSWindow *myWindow;
	
	DFSGenerator *generator;
	
	PTS_DIR ptsList[10000];
	NSInteger ptsListCount;
	
	@public
	BOOL visited[128][128];
	NSInteger colCount, rowCount;
	NSRect labyRect;
	
	double speed;
	double waitingSeconds;
	BOOL playSound;
	
	NSInteger size;
	
	PTS startPoint, marker, endPoint;
	
	BOOL isGenerating, isRunning, random;
}
@property (retain) IBOutlet NSWindow *myWindow;
- (IBAction)pushApply:(id)sender;

@property (assign) double speed, waitingSeconds;
@property (assign) BOOL playSound, random;
@property (assign) NSInteger size;
@property (copy) NSColor *backgroundColor, *gridColor, *solutionColor;

- (void)didFinish;

- (BOOL)position:(PTS)pts canGo:(TADirection)dir;
@end
