//
//  Defender.h
//  TestBezier
//
//  Created by KirbyGee on 3/1/13.
//
//
#import "CCSprite.h"
#import "WideReceivers.h"

@interface Defender : CCSprite{
   int playerNumber;
   int i;
}

-(id) initWithFile:(NSString *)filename;
-(id) followPlayer: (WideReceivers*) player;
-(id) pickaPlayer;
-(int) getThePlayer;

@end
