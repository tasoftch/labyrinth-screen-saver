//
//  LabyrinthView.m
//  Labyrinth
//
//  Created by Thomas Abplanalp on 10.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import "LabyrinthView.h"

@implementation NSColor (Integrable)
+ (id)colorWithInteger:(NSInteger)integer {
	CGFloat value = (CGFloat)integer;
	
	CGFloat red, green;
	
	red = floor(value / 256.0 / 256.0);
	value -= red * 256.0 * 256.0;
	
	green = floor(value / 256.0);
	
	value -= green * 256.0;
	
	return [NSColor colorWithCalibratedRed:red / 255.0 green:green / 255.0 blue:value / 255.0 alpha:1.0];
}

- (NSInteger)integerValue {
	int red, green, blue;
	if([[self colorSpaceName] isEqualToString:@"NSCalibratedWhiteColorSpace"]) {
		red = [self whiteComponent] * 255.0;
		green = blue = red;
	}
	else {
		red = round([self redComponent] * 255.0);
		green = round([self greenComponent] * 255.0);
		blue = round([self blueComponent] * 255.0);
	}
	red = red << 16;
	green = green << 8;
	
	return red | green | blue;
}
@end




@implementation LabyrinthView
@synthesize myWindow, speed, size, backgroundColor, gridColor, solutionColor, playSound, waitingSeconds, random;

- (void)dealloc
{
    self.backgroundColor = nil;
	self.gridColor = nil;
	self.solutionColor = nil;
	self.myWindow = nil;
	[generator release];
	
    [super dealloc];
}


- (void)calculate {
	double space = 32;
	if(size == 1)
		space = 48;
	if(size == 2)
		space = 64;
	NSRect frame = self.frame;
	rowCount = floor(frame.size.height / space);
	colCount = floor(frame.size.width / space);
	
	labyRect.size = NSMakeSize(colCount * space, rowCount * space);
	labyRect.origin.x = (frame.size.width - labyRect.size.width) / 2.0;
	labyRect.origin.y = (frame.size.height - labyRect.size.height) / 2.0;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1.0];
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"Configure" bundle:[NSBundle bundleForClass:[self class]]];
		[nib instantiateWithOwner:self topLevelObjects:NULL];
		[nib release];
		
		ScreenSaverDefaults *defs = [ScreenSaverDefaults defaultsForModuleWithName:@"ch.tasoft.screensaver.labyrinth"];
		
		NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"defaults" ofType:@"plist"];
		NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:path];
		
		[defs registerDefaults:defaults];
		
		[self addObserver:self forKeyPath:@"speed" options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew context:NULL];
		
		self.speed = [defs doubleForKey:@"speed"];
		self.waitingSeconds = [defs doubleForKey:@"waitingSeconds"];
		self.playSound = [defs boolForKey:@"playSound"];
		self.random = [defs boolForKey:@"random"];
		
		self.size = [defs integerForKey:@"size"];
		self.backgroundColor = [NSColor colorWithInteger:[defs integerForKey:@"backgroundColor"]];
		self.gridColor = [NSColor colorWithInteger:[defs integerForKey:@"gridColor"]];
		self.solutionColor = [NSColor colorWithInteger:[defs integerForKey:@"solutionColor"]];
		
		
		
		generator = [[DFSGenerator alloc] init];
		[NSBezierPath setDefaultLineWidth:2.5];
		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		
		[self calculate];
		[generator generateInView:self];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self setAnimationTimeInterval:1.0 / speed];
	
	if(speed < 0.1)
		self.speed = .3;
	
	if([keyPath isEqualToString:@"size"]) {
		[generator generateInView:self];
	}
}


- (void)startAnimation
{
    [super startAnimation];
	
}

- (void)stopAnimation
{
    [super stopAnimation];
}



- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
	
	if(isGenerating)
		return;
	
	[self calculate];
	
	[gridColor set];
	
	double space = 32;
	if(size == 1)
		space = 48;
	if(size == 2)
		space = 64;
	
	[[NSBezierPath bezierPathWithRect:labyRect] stroke];
	
	NSBezierPath *horizontal = [NSBezierPath bezierPath];
	NSBezierPath *vertical = [NSBezierPath bezierPath];
	NSBezierPath *startPointer = [NSBezierPath bezierPath];
	NSBezierPath *endPointer = [NSBezierPath bezierPath];
	
	for(int row=0;row<rowCount;row++) {
		for(int col=0;col<colCount;col++) {
			NSPoint start = NSMakePoint(labyRect.origin.x + col*space+space, labyRect.origin.y + row*space);
			NSPoint bottom = NSMakePoint(labyRect.origin.x + col*space, labyRect.origin.y + row*space);
			NSPoint right = NSMakePoint(labyRect.origin.x + col*space+space, labyRect.origin.y + row*space+space);
			
			if(col == 0) {
				if(row == startPoint.row) {
					[startPointer moveToPoint:bottom];
					[startPointer lineToPoint:NSMakePoint(labyRect.origin.x + col*space, labyRect.origin.y + row*space+space)];
				}
			}
			
			if(col == endPoint.col) {
				if(row == endPoint.row) {
					[endPointer moveToPoint:start];
					[endPointer lineToPoint:right];
				}
			}
			
			
			NSInteger imp = impermeables[row][col];
			if(imp & TABottomImpermeable) {
				[horizontal moveToPoint:start];
				[horizontal lineToPoint:bottom];
			}
			
			if(imp & TARightImpermeable) {
				[vertical moveToPoint:start];
				[vertical lineToPoint:right];
			}
		}
	}
	
	[vertical stroke];
	[horizontal stroke];
	

	
	// Solution
	
	NSBezierPath *solution = [NSBezierPath bezierPath];
	[solution setLineJoinStyle:NSRoundLineJoinStyle];
	[solution setLineWidth:space * .85];
	
	[solution moveToPoint:NSMakePoint(labyRect.origin.x + space / 2.0, labyRect.origin.y + startPoint.row * space + space / 2.0)];
	
	for(int e=0;e < ptsListCount;e++) {
		PTS_DIR dir = ptsList[e];
		PTS cur = dir.pts;
		
		[solution lineToPoint:NSMakePoint(
										  labyRect.origin.x + cur.col * space + space/2.0,
										  labyRect.origin.y + cur.row * space + space/2.0)];
	}
	
	[solutionColor set];
	[solution stroke];
	
	[[NSColor redColor] set];
	[startPointer setLineWidth:space * .25];
	[startPointer stroke];
	
	[[NSColor blueColor] set];
	[endPointer setLineWidth:space * .25];
	[endPointer stroke];
}


- (void)restartLaby:(id)sender {
	ptsListCount = 0;
	
	if(random) {
		NSInteger i = 65535 + (rand() % 16711681);
		self.solutionColor = [NSColor colorWithInteger:i];
	}
	[self calculate];
	[generator generateInView:self];
}


- (void)labyCompleted {
	if(playSound)
		[[NSSound soundNamed:@"Glass"] play];
	
	[NSTimer scheduledTimerWithTimeInterval:self.waitingSeconds target:self selector:@selector(restartLaby:) userInfo:nil repeats:NO];
}


- (BOOL)position:(PTS)pts canGo:(TADirection)dir {
	if(dir == TARight) {
		if(pts.col+1==colCount) {
			return NO;
		}
		NSInteger imp = impermeables[pts.row][pts.col];
		
		if(visited[pts.row][pts.col+1]) {
			return NO;
		}
		
		
		
		if(imp & TARightImpermeable) {
			return NO;
		}
	}
	if(dir == TABottom) {
		if(pts.row == 0) {
			return NO;
		}
		NSInteger imp = impermeables[pts.row][pts.col];
		if(visited[pts.row-1][pts.col]) {
			return NO;
		}
		
		if(imp & TABottomImpermeable) {
			return NO;
		}
	}
	if(dir == TALeft) {
		if(pts.col < 1) {
			return NO;
		}
			
		NSInteger imp = impermeables[pts.row][pts.col-1];
		if(visited[pts.row][pts.col-1]) {
			return NO;
		}
		
		if(imp & TARightImpermeable) {
			return NO;
		}
	}
	if(dir == TATop) {
		if(pts.row+1>=rowCount) {
			return NO;
		}
		
		NSInteger imp = impermeables[pts.row+1][pts.col];
		if(visited[pts.row+1][pts.col]) {
			return NO;
		}
		if(imp & TABottomImpermeable) {
			return NO;
		}
	}
	return YES;
}

- (void)animateOneFrame
{	
	if(ptsListCount < 1 || !isRunning)
		return;
	
	PTS_DIR last = ptsList[ptsListCount - 1];
	TADirection dir = [self getRandomDirection:last.pts fromDirection:last.dir];
	
	
	
	if(dir != -1) {
		PTS_DIR next;
		next.dir = dir;
		if(dir==TALeft)
			next.pts = MAKE_PTS(last.pts.col-1, last.pts.row);
		if(dir==TARight)
			next.pts = MAKE_PTS(last.pts.col+1, last.pts.row);
		if(dir==TATop)
			next.pts = MAKE_PTS(last.pts.col, last.pts.row+1);
		if(dir==TABottom)
			next.pts = MAKE_PTS(last.pts.col, last.pts.row-1);
		
		
		
		
		
		ptsList[ptsListCount++] = next;
		visited[next.pts.row][next.pts.col] = YES;
		
		if(next.pts.row == endPoint.row && next.pts.col == endPoint.col) {
			PTS_DIR _dir = next;
			_dir.pts.col++;
			ptsList[ptsListCount++] = _dir;
			isRunning = NO;
			[self setNeedsDisplay:YES];
			[self labyCompleted];
			return;
		}
	}
	else
		ptsListCount--;
	
	[self setNeedsDisplay:YES];
	return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    return myWindow;
}

- (TADirection)getRandomDirection:(PTS)point fromDirection:(TADirection)oldDir {
	TADirection dirs[4];
	NSInteger count = 0;
	
	if([self position:point canGo:TALeft] && oldDir != TARight)
		dirs[count++] = TALeft;
	if([self position:point canGo:TARight] && oldDir != TALeft)
		dirs[count++] = TARight;
	if([self position:point canGo:TATop] && oldDir != TABottom)
		dirs[count++] = TATop;
	if([self position:point canGo:TABottom] && oldDir != TATop)
		dirs[count++] = TABottom;
	
	if(count == 0)
		return -1;
	
	int c = rand() % count;
	return dirs[c];
}

- (void)didFinish {
	ptsListCount = 2;
	PTS_DIR _dir;
	
	_dir.pts = startPoint;
	_dir.pts.col--;
	_dir.dir = TARight;
	
	ptsList[0] = _dir;
	
	PTS_DIR dir;
	dir.pts = startPoint;
	dir.dir = [self getRandomDirection:startPoint fromDirection:-1];
	ptsList[1] = dir;
	visited[startPoint.row][startPoint.col] = YES;
	isRunning = YES;
	[self setNeedsDisplay:YES];
}

- (IBAction)pushApply:(id)sender {
	[NSApp endSheet:myWindow];
	[myWindow orderOut:nil];
	
	ScreenSaverDefaults *defs = [ScreenSaverDefaults defaultsForModuleWithName:@"ch.tasoft.screensaver.labyrinth"];
	
	[defs setInteger:size forKey:@"size"];
	[defs setDouble:speed forKey:@"speed"];
	[defs setDouble:waitingSeconds forKey:@"waitingSeconds"];
	[defs setBool:playSound forKey:@"playSound"];
	[defs setBool:random forKey:@"random"];
	
	[defs setInteger:[backgroundColor integerValue] forKey:@"backgroundColor"];
	[defs setInteger:[gridColor integerValue] forKey:@"gridColor"];
	[defs setInteger:[solutionColor integerValue] forKey:@"solutionColor"];
	
	[defs synchronize];
	
	ptsListCount = 0;
	[self calculate];
	[generator generateInView:self];
}
@end
