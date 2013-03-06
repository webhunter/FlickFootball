//
//  Defender.h
//  TestBezier
//
//  Created by KirbyGee on 3/1/13.
//
//
#import "CCSprite.h"
#import "WideReceivers.h"
#import "Singleton.h"
@interface Defender : CCSprite{
   int playerNumber;
   bool defenderPlacementBool;
   WideReceivers *followPlayer;
}

-(id) initWithFile:(NSString *)filename;
-(id) followPlayer: (WideReceivers*) player;
@property (readwrite) bool followPlayerBool;

@end
