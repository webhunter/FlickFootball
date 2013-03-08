//
//  CopyBall.m
//  TestBezier
//
//  Created by KirbyGee on 3/5/13.
//
//

#import "CopyBall.h"
#import "HelloWorldLayer.h"
#import "Singleton.h"

@implementation CopyBall
-(id) initWithFile:(NSString *)filename {
	if ((self = [super initWithFile:filename])) {
   }
   return self;
}
-(CCSprite*)getSticky{
   return stickyplayer;
}
-(id) setPlayerToStick:(CCSprite*)sender{
   stickyplayer = sender;
   return self;
}
-(void) removeCopied:(id)sender{
   [Singleton sharedSingleron].ballToPlayer = NO;

   [[self parent] removeChild:self cleanup:YES];

}
-(void) fadeCopiedBall:(id)sender{
   id fade = [CCFadeOut actionWithDuration:2.51f];
   id callBack = [CCCallFunc actionWithTarget:self selector:@selector(removeCopied:)];
   [self runAction:[CCSequence actions:fade, callBack, nil]];
}
-(id) fadeAndRemove{
   [self performSelector:@selector(fadeCopiedBall:) withObject:nil afterDelay:1.0f];
   
   return self;
}
@end
