//
//  CopyBall.h
//  TestBezier
//
//  Created by KirbyGee on 3/5/13.
//
//

#import "CCSprite.h"
#import "Ball.h"

@interface CopyBall : CCSprite{
   CCSprite *stickyplayer;
}
-(id) initWithFile:(NSString *)filename;
-(id) fadeAndRemove;
-(id) setPlayerToStick:(CCSprite*)sender;
-(CCSprite*)getSticky;

@end
