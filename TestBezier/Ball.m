//
//  Ball.m
//  TestBezier
//
//  Created by KirbyGee on 2/21/13.
//
//

#import "Ball.h"
#import "HelloWorldLayer.h"
@implementation Ball

extern CGPoint endPosition;


-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
      
      NSLog(@"Endpt: %@", NSStringFromCGPoint(endPosition));
   }
   return self;
}
@end
