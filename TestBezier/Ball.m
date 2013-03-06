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

-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
   }
   return self;
}

-(id) followPlayer:(CCSprite*)playerToFollow{
   player = playerToFollow;
   
   return self;
}
-(CCSprite*) createCopy{
   ballCopy = [CCSprite spriteWithFile:@"Player2.png"];
   ballCopy.position = self.position;
   ballCopy.color = ccRED;
   //[self addChild:ballCopy z:20];
   
   return ballCopy;
}

@end
