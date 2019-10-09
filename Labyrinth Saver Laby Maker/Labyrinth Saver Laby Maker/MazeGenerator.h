//
//  MazeGenerator.h
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 12.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabyView.h"

@interface LabyView (Generator)
- (BOOL)hasStartPoint;

- (void)addWallAtPosition:(NSPoint)pt horizontally:(BOOL)flag;
- (void)removeWallAtPosition:(NSPoint)pt horizontally:(BOOL)flag;
@end

@interface MazeGenerator : NSObject {
	LabyView *labyrinth;
	BOOL generateSlowly, canGenerate;
	NSInteger generatorType;
	
	BOOL isGenerating;
	IBOutlet NSButton *triggerButton;
}
@property (assign) IBOutlet LabyView *labyrinth;

@property (assign) BOOL generateSlowly, canGenerate, isGenerating;
@property ( assign ) NSInteger generatorType;

- (IBAction)generateMaze:(id)sender;

- (void)didFinish;
@end
