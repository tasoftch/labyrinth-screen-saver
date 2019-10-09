//
//  MazeGenerator.m
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 12.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import "MazeGenerator.h"
#import "DFSGenerator.h"




@implementation LabyView (Generator)
- (BOOL)hasStartPoint {
	return (startPoint.x < 0) ? NO : YES;
}

- (void)addWallAtPosition:(NSPoint)pt horizontally:(BOOL)flag {
	if(flag)
		impH[(NSInteger)pt.y][(NSInteger)pt.x] = YES;
	else
		impV[(NSInteger)pt.y][(NSInteger)pt.x] = YES;
}

- (void)removeWallAtPosition:(NSPoint)pt horizontally:(BOOL)flag {
	if(flag)
		impH[(NSInteger)pt.y][(NSInteger)pt.x] = NO;
	else
		impV[(NSInteger)pt.y][(NSInteger)pt.x] = NO;
}
@end


@implementation MazeGenerator
@synthesize labyrinth, generateSlowly, generatorType, canGenerate, isGenerating;

- (void)didFinish {
	[self cancel:triggerButton];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.generateSlowly = YES;
		self.generatorType = 0;
		
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			while(![labyrinth hasStartPoint]) {
				[NSThread sleepForTimeInterval:0.2];
			}
			
			self.canGenerate = YES;
		});
    }
    return self;
}

- (IBAction)cancel:(id)sender {
	isGenerating = NO;
	[sender setTitle:@"Generate"];
	[sender setAction:@selector(generateMaze:)];
	
	labyrinth->marker = OrderOutPoint;
	[labyrinth setNeedsDisplay:YES];
}

- (IBAction)generateMaze:(id)sender {
	isGenerating = YES;
	[sender setTitle:@"Stop"];
	[sender setAction:@selector(cancel:)];
	
	if(generatorType == 0) {
		DFSGenerator *gen = [[DFSGenerator alloc] init];
		gen->main = self;
		[gen generateInView:labyrinth withOptions:generateSlowly ? 1 : 0];
	}
	else {
		NSBeep();
		NSRunAlertPanel(@"Warning", @"The selected Generator can not be used!", @"OK", nil, nil);
		[self cancel:sender];
	}
}
@end
