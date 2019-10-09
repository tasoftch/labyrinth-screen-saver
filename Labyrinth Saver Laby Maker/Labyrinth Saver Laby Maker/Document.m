//
//  Document.m
//  Labyrinth Saver Laby Maker
//
//  Created by Thomas Abplanalp on 10.08.12.
//  Copyright (c) 2012 Thomas Abplanalp. All rights reserved.
//

#import "Document.h"

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
		
    }
    return self;
}

- (NSString *)windowNibName
{
	return @"Document";
}

- (void)dealloc
{
    [stackData release];
    [super dealloc];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSData *data = [labyView dataRepresentation];
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	stackData = [data retain];
	return YES;
}

- (void)awakeFromNib {
	[drawer open];
	
	if(stackData)
		[labyView reloadWithDataRepresentation:stackData];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
	double max = MAX(frameSize.width, frameSize.height);
	return NSMakeSize(max-22.0, max);
}
@end
